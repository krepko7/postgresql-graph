-- ============================================================
-- Script: 04-update-graph.sql
-- Purpose: Demonstrate how to update graph data (nodes & edges)
-- Prerequisites: Run 01, 02, 03 scripts first
-- ============================================================

-- earch path

SET search_path = ag_catalog, "$user", public;

-- ============================================================
-- UPDATE NODE PROPERTIES
-- ============================================================

-- 1. Promote Bob Martinez to Staff Developer
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Bob Martinez'})
    SET p.title = 'Staff Developer', p.promoted_date = '2024-09-01'
    RETURN p.name, p.title, p.promoted_date
$$) AS (name agtype, title agtype, promoted_date agtype);

-- 2. Update project status: Nova moves from planning to active
SELECT * FROM cypher('techcorp', $$
    MATCH (proj:Project {name: 'Nova'})
    SET proj.status = 'active', proj.actual_start_date = '2024-07-15'
    RETURN proj.name, proj.status, proj.actual_start_date
$$) AS (name agtype, status agtype, start_date agtype);

-- 3. Increase Phoenix project budget
SELECT * FROM cypher('techcorp', $$
    MATCH (proj:Project {name: 'Phoenix'})
    SET proj.budget = 600000, proj.budget_revised_date = '2024-08-01'
    RETURN proj.name, proj.budget, proj.budget_revised_date
$$) AS (name agtype, budget agtype, revised agtype);

-- 4. Update Nathan Wright's location (moved to Seattle)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Nathan Wright'})
    SET p.location = 'Seattle', p.relocation_date = '2024-10-01'
    RETURN p.name, p.location, p.relocation_date
$$) AS (name agtype, location agtype, relocation_date agtype);

-- ============================================================
-- ADD NEW NODES
-- ============================================================

-- 5. Add a new employee
SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 16, name: 'Sam Rivera', title: 'Platform Engineer',
        department: 'Infrastructure', email: 'sam.rivera@techcorp.com',
        hire_date: '2024-08-15', location: 'Seattle'
    })
$$) AS (v agtype);

-- 6. Add a new project
SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 109, name: 'Quantum', description: 'AI-powered testing framework',
        status: 'planning', start_date: '2024-10-01',
        technology: 'Python/LangChain', budget: 275000
    })
$$) AS (v agtype);

-- 7. Add a new skill
SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 216, name: 'LangChain', category: 'AI Framework', level_description: 'LLM orchestration'})
$$) AS (v agtype);

-- ============================================================
-- ADD NEW EDGES
-- ============================================================

-- 8. Sam Rivera joins the Platform Team
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Sam Rivera'}), (t:Team {name: 'Platform Team'})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2024-08-15'}]->(t)
$$) AS (r agtype);

-- 9. Sam Rivera works on Titan project
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Sam Rivera'}), (proj:Project {name: 'Titan'})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2024-09-01', hours_per_week: 35}]->(proj)
$$) AS (r agtype);

-- 10. Alice Chen manages Sam Rivera
SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {name: 'Alice Chen'}), (e:Person {name: 'Sam Rivera'})
    CREATE (m)-[:MANAGES {since: '2024-08-15'}]->(e)
$$) AS (r agtype);

-- 11. Grace Patel now works on the new Quantum project
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Grace Patel'}), (proj:Project {name: 'Quantum'})
    CREATE (p)-[:WORKS_ON {role: 'Tech Lead', since: '2024-10-01', hours_per_week: 30}]->(proj)
$$) AS (r agtype);

-- 12. Sam Rivera has Kubernetes and Terraform skills
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Sam Rivera'}), (s:Skill {name: 'Kubernetes'})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Sam Rivera'}), (s:Skill {name: 'Terraform'})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 4}]->(s)
$$) AS (r agtype);

-- ============================================================
-- UPDATE EDGE PROPERTIES
-- ============================================================

-- 13. Increase David Kim's hours on Titan (taking on more responsibility)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'David Kim'})-[w:WORKS_ON]->(proj:Project {name: 'Titan'})
    SET w.hours_per_week = 30, w.role = 'Senior Tech Lead'
    RETURN p.name, proj.name, w.role, w.hours_per_week
$$) AS (person agtype, project agtype, role agtype, hours agtype);

-- 14. Update Nathan Wright's skill proficiency (he's been learning!)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Nathan Wright'})-[h:HAS_SKILL]->(s:Skill {name: 'TypeScript'})
    SET h.proficiency = 'advanced', h.years_experience = 2
    RETURN p.name, s.name, h.proficiency, h.years_experience
$$) AS (person agtype, skill agtype, proficiency agtype, years agtype);

-- 15. Bob Martinez starts mentoring Sam Rivera
SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person {name: 'Bob Martinez'}), (mentee:Person {name: 'Sam Rivera'})
    CREATE (mentor)-[:MENTORS {focus_area: 'Platform Engineering', since: '2024-09-01'}]->(mentee)
$$) AS (r agtype);

-- ============================================================
-- DELETE EDGES
-- ============================================================

-- 16. Frank Lee is no longer working on Echo (project completed)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Frank Lee'})-[w:WORKS_ON]->(proj:Project {name: 'Echo'})
    DELETE w
$$) AS (r agtype);

-- 17. Reduce Grace Patel's hours on Nova (splitting time with Quantum)
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Grace Patel'})-[w:WORKS_ON]->(proj:Project {name: 'Nova'})
    SET w.hours_per_week = 20
    RETURN p.name, proj.name, w.hours_per_week
$$) AS (person agtype, project agtype, hours agtype);

-- ============================================================
-- DELETE NODES (must remove edges first)
-- ============================================================

-- 18. Remove the completed Echo project and all its relationships
SELECT * FROM cypher('techcorp', $$
    MATCH (proj:Project {name: 'Echo'})
    DETACH DELETE proj
$$) AS (r agtype);

-- ============================================================
-- VERIFY UPDATES
-- ============================================================

-- Check Bob's new title
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Bob Martinez'})
    RETURN p.name, p.title, p.promoted_date
$$) AS (name agtype, title agtype, promoted agtype);

-- Check new employee exists
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Sam Rivera'})-[r]->(n)
    RETURN p.name, type(r) AS relationship, labels(n) AS target_type
$$) AS (name agtype, relationship agtype, target_type agtype);

-- Check updated node counts
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person) RETURN 'People' AS label, count(p) AS count
$$) AS (label agtype, count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Project) RETURN 'Projects' AS label, count(p) AS count
$$) AS (label agtype, count agtype);
