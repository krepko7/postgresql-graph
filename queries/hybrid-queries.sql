-- ============================================================
-- Hybrid SQL/Cypher Queries for the TechCorp Graph
-- Purpose: Demonstrate combining SQL and Cypher with Apache AGE
-- These queries show the power of mixing graph traversals with
-- relational SQL operations.
-- Prerequisites: Run all load scripts first
-- ============================================================

-- IMPORTANT: Run this line at the start of every session
SET search_path = ag_catalog, "$user", public;

-- ============================================================
-- HYBRID QUERY BASICS
-- AGE embeds Cypher inside SQL using the cypher() function.
-- You can use the results like any other SQL subquery.
-- ============================================================

-- 1. Use SQL to filter Cypher results with LIKE patterns
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    RETURN p.name, p.title, proj.name, w.role
$$) AS (person_name agtype, person_title agtype, project_name agtype, role agtype)
WHERE person_name::text LIKE '%Martinez%';

-- 2. Use SQL aggregation on top of Cypher results
SELECT project_name, COUNT(*) AS member_count, SUM(hours::int) AS total_hours
FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    RETURN proj.name, w.hours_per_week
$$) AS (project_name agtype, hours agtype)
GROUP BY project_name
ORDER BY total_hours DESC;

-- 3. Use SQL CASE expressions on graph data
SELECT
    person_name,
    skill_name,
    CASE
        WHEN proficiency::text = '"expert"' THEN 'Senior-level'
        WHEN proficiency::text = '"advanced"' THEN 'Mid-level'
        ELSE 'Junior-level'
    END AS skill_level
FROM cypher('techcorp', $$
    MATCH (p:Person)-[h:HAS_SKILL]->(s:Skill)
    RETURN p.name, s.name, h.proficiency
$$) AS (person_name agtype, skill_name agtype, proficiency agtype)
ORDER BY person_name;

-- ============================================================
-- COMBINING CYPHER RESULTS WITH SQL TABLES
-- ============================================================

-- 4. Create a relational table for project budgets (to join with graph)
CREATE TABLE IF NOT EXISTS project_budget_tracking (
    project_name TEXT PRIMARY KEY,
    q1_spend NUMERIC,
    q2_spend NUMERIC,
    remaining_budget NUMERIC
);

INSERT INTO project_budget_tracking VALUES
    ('Phoenix', 125000, 130000, 245000),
    ('Atlas', 80000, 95000, 175000),
    ('Titan', 70000, 72000, 138000),
    ('Horizon', 75000, 80000, 145000),
    ('Sentinel', 100000, 95000, 185000),
    ('Compass', 40000, 55000, 105000)
ON CONFLICT (project_name) DO NOTHING;

-- 5. Join graph query results with relational table
SELECT
    g.project_name,
    g.team_size,
    b.q1_spend,
    b.q2_spend,
    b.remaining_budget,
    ROUND(b.remaining_budget / NULLIF(g.team_size::int, 0)) AS budget_per_person
FROM (
    SELECT project_name, team_count
    FROM cypher('techcorp', $$
        MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
        RETURN proj.name, count(p)
    $$) AS (project_name agtype, team_count agtype)
) AS g(project_name, team_size),
project_budget_tracking b
WHERE b.project_name = g.project_name::text
ORDER BY budget_per_person DESC;

-- ============================================================
-- ADVANCED HYBRID PATTERNS
-- ============================================================

-- 6. Window functions on graph results - rank people by skill count
SELECT
    person_name,
    skill_count,
    RANK() OVER (ORDER BY skill_count::int DESC) AS skill_rank
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
    RETURN p.name, count(s)
$$) AS (person_name agtype, skill_count agtype);

-- 7. CTE (Common Table Expression) with graph queries
WITH team_skills AS (
    SELECT team_name, skill_name
    FROM cypher('techcorp', $$
        MATCH (p:Person)-[:BELONGS_TO]->(t:Team)
        MATCH (p)-[:HAS_SKILL]->(s:Skill)
        RETURN t.name, s.name
    $$) AS (team_name agtype, skill_name agtype)
),
skill_counts AS (
    SELECT team_name, COUNT(DISTINCT skill_name) AS unique_skills
    FROM team_skills
    GROUP BY team_name
)
SELECT * FROM skill_counts ORDER BY unique_skills DESC;

-- 8. Subquery: Find people whose projects depend on infrastructure
SELECT DISTINCT person_name, project_name
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:WORKS_ON]->(proj:Project)-[:DEPENDS_ON]->(dep:Project)
    WHERE dep.name = 'Titan'
    RETURN p.name, proj.name
$$) AS (person_name agtype, project_name agtype);

-- 9. UNION of multiple graph queries
SELECT person_name, relationship_type, related_to
FROM (
    SELECT person_name, 'MANAGES'::text AS relationship_type, employee_name AS related_to
    FROM cypher('techcorp', $$
        MATCH (m:Person)-[:MANAGES]->(e:Person)
        RETURN m.name, e.name
    $$) AS (person_name agtype, employee_name agtype)

    UNION ALL

    SELECT person_name, 'MENTORS'::text AS relationship_type, mentee_name AS related_to
    FROM cypher('techcorp', $$
        MATCH (m:Person)-[:MENTORS]->(e:Person)
        RETURN m.name, e.name
    $$) AS (person_name agtype, mentee_name agtype)
) combined
ORDER BY person_name, relationship_type;

-- ============================================================
-- ANALYTICAL HYBRID QUERIES
-- ============================================================

-- 10. Cross-team collaboration: find people on the same project from different teams
SELECT
    p1_name AS person1,
    p2_name AS person2,
    project_name,
    t1_name AS team1,
    t2_name AS team2
FROM cypher('techcorp', $$
    MATCH (p1:Person)-[:WORKS_ON]->(proj:Project)<-[:WORKS_ON]-(p2:Person)
    MATCH (p1)-[:BELONGS_TO]->(t1:Team)
    MATCH (p2)-[:BELONGS_TO]->(t2:Team)
    WHERE p1.id < p2.id AND t1 <> t2
    RETURN p1.name, p2.name, proj.name, t1.name, t2.name
$$) AS (p1_name agtype, p2_name agtype, project_name agtype, t1_name agtype, t2_name agtype);

-- 11. Skill gap analysis: projects and their team's missing skills
-- Find skills needed by project technology vs skills the team has
SELECT
    project_name,
    person_name,
    person_skills
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:WORKS_ON]->(proj:Project {name: 'Phoenix'})
    MATCH (p)-[:HAS_SKILL]->(s:Skill)
    RETURN proj.name, p.name, collect(s.name)
$$) AS (project_name agtype, person_name agtype, person_skills agtype);

-- 12. Management span analysis with SQL aggregation
SELECT
    manager_name,
    direct_reports,
    CASE
        WHEN direct_reports::int > 4 THEN 'Wide span - consider splitting'
        WHEN direct_reports::int <= 2 THEN 'Narrow span - can take more'
        ELSE 'Optimal span'
    END AS recommendation
FROM cypher('techcorp', $$
    MATCH (m:Person)-[:MANAGES]->(e:Person)
    RETURN m.name, count(e)
$$) AS (manager_name agtype, direct_reports agtype)
ORDER BY direct_reports DESC;

-- 13. Project risk: dependencies and team allocation
WITH project_deps AS (
    SELECT project_name, dep_count
    FROM cypher('techcorp', $$
        MATCH (p:Project)-[:DEPENDS_ON]->(d:Project)
        RETURN p.name, count(d)
    $$) AS (project_name agtype, dep_count agtype)
),
project_team AS (
    SELECT project_name, team_size, total_hours
    FROM cypher('techcorp', $$
        MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
        RETURN proj.name, count(p), sum(w.hours_per_week)
    $$) AS (project_name agtype, team_size agtype, total_hours agtype)
)
SELECT
    pt.project_name,
    pt.team_size,
    pt.total_hours,
    COALESCE(pd.dep_count, '0'::agtype) AS dependencies,
    CASE
        WHEN pd.dep_count::int > 1 AND pt.team_size::int < 3
        THEN 'HIGH RISK: many dependencies, small team'
        WHEN pd.dep_count::int > 0
        THEN 'MEDIUM RISK: has dependencies'
        ELSE 'LOW RISK'
    END AS risk_level
FROM project_team pt
LEFT JOIN project_deps pd ON pt.project_name = pd.project_name
ORDER BY risk_level;

-- 14. Create a materialized view from graph data for reporting
CREATE MATERIALIZED VIEW IF NOT EXISTS team_summary AS
SELECT
    team_name,
    member_count,
    CURRENT_TIMESTAMP AS refreshed_at
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:BELONGS_TO]->(t:Team)
    RETURN t.name, count(p)
$$) AS (team_name agtype, member_count agtype);

-- Query the materialized view
SELECT * FROM team_summary ORDER BY member_count DESC;

-- Refresh it when data changes
-- REFRESH MATERIALIZED VIEW team_summary;

-- ============================================================
-- CLEANUP (optional)
-- ============================================================

-- Drop the budget tracking table if no longer needed
-- DROP TABLE IF EXISTS project_budget_tracking;
-- DROP MATERIALIZED VIEW IF EXISTS team_summary;
