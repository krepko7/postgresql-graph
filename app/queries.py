"""
Query definitions for the Streamlit Graph Workshop app.
Each query set contains: SQL equivalent, Cypher via AGE, and hybrid SQL/Cypher.
"""

QUERY_CATEGORIES = {
    "Basic Lookups": {
        "Find all people and their roles": {
            "sql": """
SELECT id, name, title, department, location
FROM techcorp._ag_label_vertex
WHERE properties->>'label' = 'Person'
ORDER BY properties->>'name';

-- NOTE: In AGE, nodes are stored in label tables.
-- Direct SQL access is possible but requires understanding internal structure.
-- The above is a simplified example; actual table is techcorp."Person"
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)
    RETURN p.name, p.title, p.department, p.location
    ORDER BY p.name
$$) AS (name agtype, title agtype, department agtype, location agtype);
""",
            "hybrid": None,
            "description": "Retrieve all employees. Cypher uses pattern matching while SQL would query the internal vertex table directly."
        },
        "Find all active projects": {
            "sql": """
-- Direct SQL against AGE internal table
SELECT properties->>'name' AS name,
       properties->>'technology' AS technology,
       (properties->>'budget')::int AS budget
FROM techcorp."Project"
WHERE properties->>'status' = 'active'
ORDER BY (properties->>'budget')::int DESC;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (proj:Project {status: 'active'})
    RETURN proj.name, proj.technology, proj.budget
    ORDER BY proj.budget DESC
$$) AS (name agtype, technology agtype, budget agtype);
""",
            "hybrid": None,
            "description": "Filter projects by status. Cypher is more readable for property-based filtering."
        },
        "Count nodes by type": {
            "sql": """
-- Count vertices per label using AGE internal catalog
SELECT name AS label, count
FROM (
    SELECT 'Person' AS name, count(*) FROM techcorp."Person"
    UNION ALL
    SELECT 'Project', count(*) FROM techcorp."Project"
    UNION ALL
    SELECT 'Skill', count(*) FROM techcorp."Skill"
    UNION ALL
    SELECT 'Team', count(*) FROM techcorp."Team"
) counts(name, count)
ORDER BY count DESC;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)
    RETURN 'Person' AS label, count(p) AS count
$$) AS (label agtype, count agtype)
UNION ALL
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Project)
    RETURN 'Project' AS label, count(p) AS count
$$) AS (label agtype, count agtype)
UNION ALL
SELECT * FROM cypher('techcorp', $$
    MATCH (s:Skill)
    RETURN 'Skill' AS label, count(s) AS count
$$) AS (label agtype, count agtype)
UNION ALL
SELECT * FROM cypher('techcorp', $$
    MATCH (t:Team)
    RETURN 'Team' AS label, count(t) AS count
$$) AS (label agtype, count agtype);
""",
            "hybrid": None,
            "description": "Count all nodes. SQL requires knowing internal table names; Cypher uses labels naturally."
        },
    },

    "Relationship Traversal": {
        "Who works on Phoenix?": {
            "sql": """
-- SQL requires joining internal edge and vertex tables
SELECT p.properties->>'name' AS person,
       e.properties->>'role' AS role,
       (e.properties->>'hours_per_week')::int AS hours
FROM techcorp."WORKS_ON" e
JOIN techcorp."Person" p ON e.start_id = p.id
JOIN techcorp."Project" proj ON e.end_id = proj.id
WHERE proj.properties->>'name' = 'Phoenix'
ORDER BY (e.properties->>'hours_per_week')::int DESC;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project {name: 'Phoenix'})
    RETURN p.name, w.role, w.hours_per_week
    ORDER BY w.hours_per_week DESC
$$) AS (name agtype, role agtype, hours agtype);
""",
            "hybrid": """
-- Hybrid: Use Cypher for traversal, SQL for aggregation
SELECT
    name,
    role,
    hours,
    RANK() OVER (ORDER BY hours::int DESC) AS workload_rank
FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project {name: 'Phoenix'})
    RETURN p.name, w.role, w.hours_per_week
$$) AS (name agtype, role agtype, hours agtype);
""",
            "description": "Find project team members. Cypher expresses the graph pattern naturally; SQL requires manual joins on internal tables."
        },
        "Find a person's skills": {
            "sql": """
-- SQL version with internal table joins
SELECT s.properties->>'name' AS skill,
       e.properties->>'proficiency' AS proficiency,
       (e.properties->>'years_experience')::int AS years
FROM techcorp."HAS_SKILL" e
JOIN techcorp."Person" p ON e.start_id = p.id
JOIN techcorp."Skill" s ON e.end_id = s.id
WHERE p.properties->>'name' = 'Alice Chen'
ORDER BY (e.properties->>'years_experience')::int DESC;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Alice Chen'})-[h:HAS_SKILL]->(s:Skill)
    RETURN s.name, h.proficiency, h.years_experience
    ORDER BY h.years_experience DESC
$$) AS (skill agtype, proficiency agtype, years agtype);
""",
            "hybrid": """
-- Hybrid: Cypher traversal + SQL CASE for human-readable output
SELECT
    skill,
    CASE
        WHEN proficiency::text = '"expert"' THEN '⭐⭐⭐ Expert'
        WHEN proficiency::text = '"advanced"' THEN '⭐⭐ Advanced'
        ELSE '⭐ Intermediate'
    END AS level,
    years
FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Alice Chen'})-[h:HAS_SKILL]->(s:Skill)
    RETURN s.name, h.proficiency, h.years_experience
    ORDER BY h.years_experience DESC
$$) AS (skill agtype, proficiency agtype, years agtype);
""",
            "description": "Get someone's skill profile. The graph pattern is intuitive in Cypher vs complex joins in SQL."
        },
        "Management hierarchy": {
            "sql": """
-- SQL recursive CTE to traverse management chain
WITH RECURSIVE mgmt_chain AS (
    SELECT p.id,
           p.properties->>'name' AS name,
           p.properties->>'title' AS title,
           1 AS level
    FROM techcorp."Person" p
    WHERE p.properties->>'name' = 'Maria Garcia'

    UNION ALL

    SELECT emp.id,
           emp.properties->>'name',
           emp.properties->>'title',
           mc.level + 1
    FROM mgmt_chain mc
    JOIN techcorp."MANAGES" e ON e.start_id = mc.id
    JOIN techcorp."Person" emp ON e.end_id = emp.id
)
SELECT name, title, level FROM mgmt_chain ORDER BY level, name;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH path = (vp:Person {name: 'Maria Garcia'})-[:MANAGES*1..3]->(emp:Person)
    RETURN emp.name, emp.title, length(path) AS depth
    ORDER BY depth, emp.name
$$) AS (name agtype, title agtype, depth agtype);
""",
            "hybrid": """
-- Hybrid: Cypher for variable-length traversal, SQL for presentation
SELECT
    name,
    title,
    depth,
    REPEAT('  ', depth::int) || '└── ' || name::text AS org_chart
FROM cypher('techcorp', $$
    MATCH path = (vp:Person {name: 'Maria Garcia'})-[:MANAGES*1..3]->(emp:Person)
    RETURN emp.name, emp.title, length(path)
$$) AS (name agtype, title agtype, depth agtype)
ORDER BY depth;
""",
            "description": "Traverse management tree. SQL needs recursive CTEs; Cypher handles variable-length paths natively with *1..3 syntax."
        },
    },

    "Multi-Hop & Pattern Matching": {
        "People who share skills": {
            "sql": """
-- SQL: Self-join through the skill relationship
SELECT DISTINCT
    p2.properties->>'name' AS colleague,
    s.properties->>'name' AS shared_skill
FROM techcorp."HAS_SKILL" e1
JOIN techcorp."Person" p1 ON e1.start_id = p1.id
JOIN techcorp."Skill" s ON e1.end_id = s.id
JOIN techcorp."HAS_SKILL" e2 ON e2.end_id = s.id
JOIN techcorp."Person" p2 ON e2.start_id = p2.id
WHERE p1.properties->>'name' = 'Bob Martinez'
  AND p2.properties->>'name' != 'Bob Martinez'
ORDER BY p2.properties->>'name';
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Person {name: 'Bob Martinez'})-[:HAS_SKILL]->(s:Skill)<-[:HAS_SKILL]-(p2:Person)
    WHERE p1 <> p2
    RETURN DISTINCT p2.name, s.name AS shared_skill
    ORDER BY p2.name
$$) AS (person agtype, shared_skill agtype);
""",
            "hybrid": """
-- Hybrid: Cypher for pattern matching, SQL for grouping
SELECT
    person,
    COUNT(*) AS shared_skill_count,
    STRING_AGG(shared_skill::text, ', ') AS skills_in_common
FROM cypher('techcorp', $$
    MATCH (p1:Person {name: 'Bob Martinez'})-[:HAS_SKILL]->(s:Skill)<-[:HAS_SKILL]-(p2:Person)
    WHERE p1 <> p2
    RETURN DISTINCT p2.name, s.name
$$) AS (person agtype, shared_skill agtype)
GROUP BY person
ORDER BY shared_skill_count DESC;
""",
            "description": "Find colleagues with overlapping skills. The diamond pattern (person→skill←person) is elegant in Cypher but requires multiple joins in SQL."
        },
        "Project dependency chain": {
            "sql": """
-- SQL: Recursive CTE for dependency chains
WITH RECURSIVE dep_chain AS (
    SELECT proj.id,
           proj.properties->>'name' AS project,
           dep.properties->>'name' AS depends_on,
           1 AS depth
    FROM techcorp."DEPENDS_ON" e
    JOIN techcorp."Project" proj ON e.start_id = proj.id
    JOIN techcorp."Project" dep ON e.end_id = dep.id

    UNION ALL

    SELECT dc.id,
           dc.project,
           dep.properties->>'name',
           dc.depth + 1
    FROM dep_chain dc
    JOIN techcorp."DEPENDS_ON" e ON e.start_id = (
        SELECT id FROM techcorp."Project" WHERE properties->>'name' = dc.depends_on
    )
    JOIN techcorp."Project" dep ON e.end_id = dep.id
    WHERE dc.depth < 5
)
SELECT project, depends_on, depth FROM dep_chain ORDER BY project, depth;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH path = (p1:Project)-[:DEPENDS_ON*1..3]->(p2:Project)
    RETURN p1.name AS project, p2.name AS depends_on, length(path) AS depth
    ORDER BY p1.name, depth
$$) AS (project agtype, depends_on agtype, depth agtype);
""",
            "hybrid": """
-- Hybrid: Cypher traversal + SQL risk assessment
WITH deps AS (
    SELECT project, depends_on, depth
    FROM cypher('techcorp', $$
        MATCH path = (p1:Project)-[:DEPENDS_ON*1..3]->(p2:Project)
        RETURN p1.name, p2.name, length(path)
    $$) AS (project agtype, depends_on agtype, depth agtype)
)
SELECT
    project,
    COUNT(*) AS total_dependencies,
    MAX(depth::int) AS max_chain_depth,
    CASE
        WHEN MAX(depth::int) >= 3 THEN '🔴 Deep chain - high risk'
        WHEN COUNT(*) > 2 THEN '🟡 Multiple deps - monitor'
        ELSE '🟢 Low risk'
    END AS risk_assessment
FROM deps
GROUP BY project
ORDER BY total_dependencies DESC;
""",
            "description": "Trace project dependencies. Variable-length paths (*1..3) in Cypher replace complex recursive CTEs in SQL."
        },
        "Cross-team collaboration": {
            "sql": """
-- SQL: Multiple joins to find cross-team project collaborators
SELECT DISTINCT
    p1.properties->>'name' AS person1,
    p2.properties->>'name' AS person2,
    proj.properties->>'name' AS project,
    t1.properties->>'name' AS team1,
    t2.properties->>'name' AS team2
FROM techcorp."WORKS_ON" w1
JOIN techcorp."Person" p1 ON w1.start_id = p1.id
JOIN techcorp."Project" proj ON w1.end_id = proj.id
JOIN techcorp."WORKS_ON" w2 ON w2.end_id = proj.id
JOIN techcorp."Person" p2 ON w2.start_id = p2.id
JOIN techcorp."BELONGS_TO" b1 ON b1.start_id = p1.id
JOIN techcorp."Team" t1 ON b1.end_id = t1.id
JOIN techcorp."BELONGS_TO" b2 ON b2.start_id = p2.id
JOIN techcorp."Team" t2 ON b2.end_id = t2.id
WHERE p1.id < p2.id AND t1.id <> t2.id
ORDER BY proj.properties->>'name';
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Person)-[:WORKS_ON]->(proj:Project)<-[:WORKS_ON]-(p2:Person)
    MATCH (p1)-[:BELONGS_TO]->(t1:Team)
    MATCH (p2)-[:BELONGS_TO]->(t2:Team)
    WHERE p1.id < p2.id AND t1 <> t2
    RETURN p1.name, p2.name, proj.name, t1.name, t2.name
$$) AS (person1 agtype, person2 agtype, project agtype, team1 agtype, team2 agtype);
""",
            "hybrid": """
-- Hybrid: Cypher for complex pattern, SQL for analytics
SELECT
    project,
    COUNT(*) AS cross_team_pairs,
    STRING_AGG(DISTINCT team1::text || ' × ' || team2::text, ', ') AS team_combinations
FROM cypher('techcorp', $$
    MATCH (p1:Person)-[:WORKS_ON]->(proj:Project)<-[:WORKS_ON]-(p2:Person)
    MATCH (p1)-[:BELONGS_TO]->(t1:Team)
    MATCH (p2)-[:BELONGS_TO]->(t2:Team)
    WHERE p1.id < p2.id AND t1 <> t2
    RETURN p1.name, p2.name, proj.name, t1.name, t2.name
$$) AS (person1 agtype, person2 agtype, project agtype, team1 agtype, team2 agtype)
GROUP BY project
ORDER BY cross_team_pairs DESC;
""",
            "description": "Find people from different teams working on the same project. The multi-pattern match in Cypher avoids 8+ table joins in SQL."
        },
    },

    "Aggregation & Analytics": {
        "Team workload summary": {
            "sql": """
-- SQL: Aggregate project hours by team
SELECT t.properties->>'name' AS team,
       COUNT(DISTINCT p.id) AS members,
       SUM((w.properties->>'hours_per_week')::int) AS total_hours
FROM techcorp."BELONGS_TO" b
JOIN techcorp."Person" p ON b.start_id = p.id
JOIN techcorp."Team" t ON b.end_id = t.id
LEFT JOIN techcorp."WORKS_ON" w ON w.start_id = p.id
GROUP BY t.properties->>'name'
ORDER BY total_hours DESC;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:BELONGS_TO]->(t:Team)
    OPTIONAL MATCH (p)-[w:WORKS_ON]->(proj:Project)
    RETURN t.name, count(DISTINCT p) AS members, sum(w.hours_per_week) AS total_hours
    ORDER BY total_hours DESC
$$) AS (team agtype, members agtype, total_hours agtype);
""",
            "hybrid": """
-- Hybrid: Cypher for graph traversal, SQL for detailed analytics
SELECT
    team,
    members,
    total_hours,
    ROUND(total_hours::numeric / NULLIF(members::int, 0), 1) AS avg_hours_per_person,
    CASE
        WHEN total_hours::int / NULLIF(members::int, 0) > 40 THEN '🔴 Overloaded'
        WHEN total_hours::int / NULLIF(members::int, 0) > 30 THEN '🟡 Busy'
        ELSE '🟢 Healthy'
    END AS workload_status
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:BELONGS_TO]->(t:Team)
    OPTIONAL MATCH (p)-[w:WORKS_ON]->(proj:Project)
    RETURN t.name, count(DISTINCT p), sum(w.hours_per_week)
$$) AS (team agtype, members agtype, total_hours agtype);
""",
            "description": "Analyze team workload. Hybrid queries excel here — Cypher for traversal, SQL for business logic and formatting."
        },
        "Most connected people": {
            "sql": """
-- SQL: Count all relationships per person
SELECT p.properties->>'name' AS person,
       (SELECT count(*) FROM techcorp."WORKS_ON" w WHERE w.start_id = p.id) +
       (SELECT count(*) FROM techcorp."HAS_SKILL" h WHERE h.start_id = p.id) +
       (SELECT count(*) FROM techcorp."BELONGS_TO" b WHERE b.start_id = p.id) +
       (SELECT count(*) FROM techcorp."MANAGES" m WHERE m.start_id = p.id) +
       (SELECT count(*) FROM techcorp."MENTORS" mt WHERE mt.start_id = p.id)
       AS total_connections
FROM techcorp."Person" p
ORDER BY total_connections DESC
LIMIT 10;
""",
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[r]->()
    RETURN p.name, count(r) AS total_connections
    ORDER BY total_connections DESC
    LIMIT 10
$$) AS (person agtype, connections agtype);
""",
            "hybrid": """
-- Hybrid: Cypher for connection counting, SQL for percentile analysis
SELECT
    person,
    connections,
    PERCENT_RANK() OVER (ORDER BY connections::int) AS percentile,
    CASE
        WHEN connections::int >= 8 THEN '🌟 Hub (highly connected)'
        WHEN connections::int >= 5 THEN '🔗 Well connected'
        ELSE '📌 Peripheral'
    END AS network_role
FROM cypher('techcorp', $$
    MATCH (p:Person)-[r]->()
    RETURN p.name, count(r)
$$) AS (person agtype, connections agtype)
ORDER BY connections DESC;
""",
            "description": "Identify the most connected employees. Cypher's open pattern -[r]->() counts all outgoing edges in one query vs multiple subqueries in SQL."
        },
        "Skill gap analysis": {
            "sql": None,
            "cypher": """
SELECT * FROM cypher('techcorp', $$
    MATCH (s:Skill)
    OPTIONAL MATCH (p:Person)-[h:HAS_SKILL {proficiency: 'expert'}]->(s)
    RETURN s.name, s.category, count(p) AS expert_count
    ORDER BY expert_count ASC
$$) AS (skill agtype, category agtype, expert_count agtype);
""",
            "hybrid": """
-- Hybrid: Cypher for skill-person relationships, SQL for gap identification
WITH skill_coverage AS (
    SELECT skill, category, expert_count
    FROM cypher('techcorp', $$
        MATCH (s:Skill)
        OPTIONAL MATCH (p:Person)-[h:HAS_SKILL {proficiency: 'expert'}]->(s)
        RETURN s.name, s.category, count(p)
    $$) AS (skill agtype, category agtype, expert_count agtype)
)
SELECT
    skill,
    category,
    expert_count,
    CASE
        WHEN expert_count::int = 0 THEN '🚨 NO EXPERTS - Critical gap!'
        WHEN expert_count::int = 1 THEN '⚠️ Single point of failure'
        ELSE '✅ Covered (' || expert_count::text || ' experts)'
    END AS coverage_status
FROM skill_coverage
ORDER BY expert_count::int ASC, skill;
""",
            "description": "Find skills with few or no experts. Hybrid query adds business-relevant risk categorization to graph traversal results."
        },
    },
}

CUSTOM_QUERY_TEMPLATE = """-- Session setup (required for every connection)

SET search_path = ag_catalog, "$user", public;

-- Write your Cypher query below:
SELECT * FROM cypher('techcorp', $$
    MATCH (n)
    RETURN labels(n) AS type, count(n) AS count
$$) AS (type agtype, count agtype);
"""
