-- ============================================================
-- Cypher Queries for the TechCorp Graph
-- Purpose: Demonstrate pure Cypher queries using Apache AGE
-- Prerequisites: Run all load scripts first
-- ============================================================

-- IMPORTANT: Run these two lines at the start of every session
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- ============================================================
-- BASIC NODE QUERIES
-- ============================================================

-- 1. Get all people
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)
    RETURN p.name, p.title, p.department
    ORDER BY p.name
$$) AS (name agtype, title agtype, department agtype);

-- 2. Get all active projects
SELECT * FROM cypher('techcorp', $$
    MATCH (proj:Project {status: 'active'})
    RETURN proj.name, proj.technology, proj.budget
    ORDER BY proj.budget DESC
$$) AS (name agtype, technology agtype, budget agtype);

-- 3. Get all skills in a specific category
SELECT * FROM cypher('techcorp', $$
    MATCH (s:Skill {category: 'Programming Language'})
    RETURN s.name, s.level_description
$$) AS (name agtype, description agtype);

-- ============================================================
-- RELATIONSHIP TRAVERSAL QUERIES
-- ============================================================

-- 4. Find all people working on a specific project
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project {name: 'Phoenix'})
    RETURN p.name, w.role, w.hours_per_week
    ORDER BY w.hours_per_week DESC
$$) AS (name agtype, role agtype, hours agtype);

-- 5. Find all projects a person works on
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Bob Martinez'})-[w:WORKS_ON]->(proj:Project)
    RETURN proj.name, w.role, proj.status
$$) AS (project agtype, role agtype, status agtype);

-- 6. Find all skills of a person
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Alice Chen'})-[h:HAS_SKILL]->(s:Skill)
    RETURN s.name, h.proficiency, h.years_experience
    ORDER BY h.years_experience DESC
$$) AS (skill agtype, proficiency agtype, years agtype);

-- 7. Find who manages whom (direct reports)
SELECT * FROM cypher('techcorp', $$
    MATCH (mgr:Person)-[:MANAGES]->(emp:Person)
    RETURN mgr.name AS manager, emp.name AS employee, mgr.title
    ORDER BY mgr.name, emp.name
$$) AS (manager agtype, employee agtype, title agtype);

-- 8. Find mentoring relationships
SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person)-[m:MENTORS]->(mentee:Person)
    RETURN mentor.name, mentee.name, m.focus_area
$$) AS (mentor agtype, mentee agtype, focus agtype);

-- ============================================================
-- MULTI-HOP QUERIES
-- ============================================================

-- 9. Find the management chain (2 levels deep)
SELECT * FROM cypher('techcorp', $$
    MATCH (vp:Person)-[:MANAGES]->(mgr:Person)-[:MANAGES]->(emp:Person)
    RETURN vp.name AS vp, mgr.name AS manager, emp.name AS employee
$$) AS (vp agtype, manager agtype, employee agtype);

-- 10. Find people who share skills with someone
SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Person {name: 'Bob Martinez'})-[:HAS_SKILL]->(s:Skill)<-[:HAS_SKILL]-(p2:Person)
    WHERE p1 <> p2
    RETURN DISTINCT p2.name, s.name AS shared_skill
    ORDER BY p2.name
$$) AS (person agtype, shared_skill agtype);

-- 11. Find project dependency chains
SELECT * FROM cypher('techcorp', $$
    MATCH path = (p1:Project)-[:DEPENDS_ON*1..3]->(p2:Project)
    RETURN p1.name AS project, p2.name AS depends_on
$$) AS (project agtype, depends_on agtype);

-- 12. Find people connected through the same team
SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Person)-[:BELONGS_TO]->(t:Team)<-[:BELONGS_TO]-(p2:Person)
    WHERE p1.id < p2.id
    RETURN p1.name, p2.name, t.name AS team
    ORDER BY t.name
$$) AS (person1 agtype, person2 agtype, team agtype);

-- ============================================================
-- AGGREGATION QUERIES
-- ============================================================

-- 13. Count people per project
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
    RETURN proj.name, count(p) AS team_size
    ORDER BY team_size DESC
$$) AS (project agtype, team_size agtype);

-- 14. Find the most skilled people (by number of skills)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
    RETURN p.name, count(s) AS skill_count
    ORDER BY skill_count DESC
    LIMIT 5
$$) AS (person agtype, skill_count agtype);

-- 15. Find the most popular skills
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
    RETURN s.name, count(p) AS people_count
    ORDER BY people_count DESC
$$) AS (skill agtype, people_count agtype);

-- 16. Total hours per project
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    RETURN proj.name, sum(w.hours_per_week) AS total_hours
    ORDER BY total_hours DESC
$$) AS (project agtype, total_hours agtype);

-- ============================================================
-- PATTERN MATCHING QUERIES
-- ============================================================

-- 17. Find people who are both a manager and a mentor
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:MANAGES]->(:Person)
    MATCH (p)-[:MENTORS]->(:Person)
    RETURN DISTINCT p.name, p.title
$$) AS (name agtype, title agtype);

-- 18. Find people who work on multiple projects
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
    WITH p, count(proj) AS project_count
    WHERE project_count > 1
    RETURN p.name, project_count
    ORDER BY project_count DESC
$$) AS (name agtype, project_count agtype);

-- 19. Find experts in infrastructure skills
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[h:HAS_SKILL {proficiency: 'expert'}]->(s:Skill {category: 'Infrastructure'})
    RETURN p.name, s.name, h.years_experience
    ORDER BY h.years_experience DESC
$$) AS (person agtype, skill agtype, years agtype);

-- 20. Shortest path between two people via any relationship
SELECT * FROM cypher('techcorp', $$
    MATCH path = shortestPath(
        (p1:Person {name: 'Nathan Wright'})-[*]-(p2:Person {name: 'Maria Garcia'})
    )
    RETURN length(path) AS path_length
$$) AS (path_length agtype);

-- ============================================================
-- CONDITIONAL & FILTERING QUERIES
-- ============================================================

-- 21. Find people in Seattle who know Python
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {location: 'Seattle'})-[:HAS_SKILL]->(s:Skill {name: 'Python'})
    RETURN p.name, p.title
$$) AS (name agtype, title agtype);

-- 22. Find remote workers and their teams
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {location: 'Remote'})-[b:BELONGS_TO]->(t:Team)
    RETURN p.name, t.name, b.role_in_team
$$) AS (name agtype, team agtype, role agtype);

-- 23. Find projects with budget over 350K and their teams
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    WHERE proj.budget > 350000
    RETURN proj.name, proj.budget, collect(p.name) AS team_members
$$) AS (project agtype, budget agtype, team agtype);

-- 24. Find people without any mentee (potential new mentors)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)
    WHERE NOT EXISTS { MATCH (p)-[:MENTORS]->() }
    AND p.title CONTAINS 'Senior' OR p.title CONTAINS 'Lead'
    RETURN p.name, p.title
$$) AS (name agtype, title agtype);
