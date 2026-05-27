-- ============================================================
-- Script: 03-load-edges.sql
-- Purpose: Load all edge/relationship data into the techcorp graph
-- Prerequisites: Run 02-load-nodes.sql first
-- ============================================================
-- Load the AGE extension and set search path
SET search_path = ag_catalog, "$user", public;

-- ============================================================
-- WORKS_ON EDGES (Person -> Project)
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 1}), (proj:Project {id: 101})
    CREATE (p)-[:WORKS_ON {role: 'Tech Lead', since: '2024-01-15', hours_per_week: 30}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (proj:Project {id: 101})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2024-01-15', hours_per_week: 40}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (proj:Project {id: 101})
    CREATE (p)-[:WORKS_ON {role: 'DevOps', since: '2024-02-01', hours_per_week: 20}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 5}), (proj:Project {id: 105})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2024-02-15', hours_per_week: 40}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 6}), (proj:Project {id: 101})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2024-01-20', hours_per_week: 35}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 6}), (proj:Project {id: 107})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2023-03-01', hours_per_week: 10}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 7}), (proj:Project {id: 104})
    CREATE (p)-[:WORKS_ON {role: 'ML Lead', since: '2024-06-01', hours_per_week: 40}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 8}), (proj:Project {id: 105})
    CREATE (p)-[:WORKS_ON {role: 'Product Owner', since: '2024-02-15', hours_per_week: 15}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 8}), (proj:Project {id: 102})
    CREATE (p)-[:WORKS_ON {role: 'Product Owner', since: '2024-03-01', hours_per_week: 15}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 3}), (proj:Project {id: 102})
    CREATE (p)-[:WORKS_ON {role: 'Data Lead', since: '2024-03-01', hours_per_week: 35}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 9}), (proj:Project {id: 105})
    CREATE (p)-[:WORKS_ON {role: 'Designer', since: '2024-02-15', hours_per_week: 30}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 10}), (proj:Project {id: 106})
    CREATE (p)-[:WORKS_ON {role: 'Tech Lead', since: '2024-01-01', hours_per_week: 40}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (proj:Project {id: 103})
    CREATE (p)-[:WORKS_ON {role: 'Tech Lead', since: '2023-11-01', hours_per_week: 20}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 11}), (proj:Project {id: 101})
    CREATE (p)-[:WORKS_ON {role: 'QA Lead', since: '2024-02-01', hours_per_week: 30}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 11}), (proj:Project {id: 105})
    CREATE (p)-[:WORKS_ON {role: 'QA', since: '2024-03-01', hours_per_week: 10}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 12}), (proj:Project {id: 102})
    CREATE (p)-[:WORKS_ON {role: 'Data Engineer', since: '2024-03-15', hours_per_week: 35}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 14}), (proj:Project {id: 108})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2024-04-01', hours_per_week: 40}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 15}), (proj:Project {id: 108})
    CREATE (p)-[:WORKS_ON {role: 'Writer', since: '2024-04-15', hours_per_week: 20}]->(proj)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (proj:Project {id: 108})
    CREATE (p)-[:WORKS_ON {role: 'Developer', since: '2024-04-01', hours_per_week: 10}]->(proj)
$$) AS (e agtype);

-- ============================================================
-- HAS_SKILL EDGES (Person -> Skill)
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 1}), (s:Skill {id: 201})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 7}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 1}), (s:Skill {id: 203})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 1}), (s:Skill {id: 209})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (s:Skill {id: 202})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (s:Skill {id: 203})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (s:Skill {id: 208})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 3}), (s:Skill {id: 201})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 6}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 3}), (s:Skill {id: 211})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 3}), (s:Skill {id: 208})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (s:Skill {id: 210})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (s:Skill {id: 209})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (s:Skill {id: 212})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 5}), (s:Skill {id: 204})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 5}), (s:Skill {id: 206})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 5}), (s:Skill {id: 205})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 6}), (s:Skill {id: 203})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 6}), (s:Skill {id: 208})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 6}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 6}), (s:Skill {id: 213})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 7}), (s:Skill {id: 201})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 7}), (s:Skill {id: 211})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 7}), (s:Skill {id: 212})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 2}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 8}), (s:Skill {id: 213})
    CREATE (p)-[:HAS_SKILL {proficiency: 'intermediate', years_experience: 2}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 9}), (s:Skill {id: 204})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 9}), (s:Skill {id: 206})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 10}), (s:Skill {id: 202})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 10}), (s:Skill {id: 214})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 10}), (s:Skill {id: 209})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 11}), (s:Skill {id: 201})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 11}), (s:Skill {id: 205})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 2}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 12}), (s:Skill {id: 201})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 12}), (s:Skill {id: 208})
    CREATE (p)-[:HAS_SKILL {proficiency: 'expert', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 12}), (s:Skill {id: 214})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 3}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 13}), (s:Skill {id: 203})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 4}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 13}), (s:Skill {id: 209})
    CREATE (p)-[:HAS_SKILL {proficiency: 'advanced', years_experience: 5}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 14}), (s:Skill {id: 205})
    CREATE (p)-[:HAS_SKILL {proficiency: 'intermediate', years_experience: 1}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 14}), (s:Skill {id: 207})
    CREATE (p)-[:HAS_SKILL {proficiency: 'intermediate', years_experience: 1}]->(s)
$$) AS (e agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 15}), (s:Skill {id: 204})
    CREATE (p)-[:HAS_SKILL {proficiency: 'intermediate', years_experience: 2}]->(s)
$$) AS (e agtype);

-- ============================================================
-- MANAGES EDGES (Person -> Person)
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 13}), (e:Person {id: 1})
    CREATE (m)-[:MANAGES {since: '2019-03-15'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 13}), (e:Person {id: 8})
    CREATE (m)-[:MANAGES {since: '2019-09-01'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 1}), (e:Person {id: 2})
    CREATE (m)-[:MANAGES {since: '2020-01-10'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 1}), (e:Person {id: 5})
    CREATE (m)-[:MANAGES {since: '2021-08-15'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 1}), (e:Person {id: 6})
    CREATE (m)-[:MANAGES {since: '2020-11-01'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 1}), (e:Person {id: 11})
    CREATE (m)-[:MANAGES {since: '2022-03-01'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 1}), (e:Person {id: 14})
    CREATE (m)-[:MANAGES {since: '2023-06-01'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 3}), (e:Person {id: 7})
    CREATE (m)-[:MANAGES {since: '2022-01-10'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 3}), (e:Person {id: 12})
    CREATE (m)-[:MANAGES {since: '2021-10-15'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 4}), (e:Person {id: 10})
    CREATE (m)-[:MANAGES {since: '2021-02-20'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 8}), (e:Person {id: 9})
    CREATE (m)-[:MANAGES {since: '2021-04-15'}]->(e)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (m:Person {id: 8}), (e:Person {id: 15})
    CREATE (m)-[:MANAGES {since: '2022-09-01'}]->(e)
$$) AS (r agtype);

-- ============================================================
-- MENTORS EDGES (Person -> Person)
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person {id: 2}), (mentee:Person {id: 14})
    CREATE (mentor)-[:MENTORS {focus_area: 'Backend Development', since: '2023-06-01'}]->(mentee)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person {id: 1}), (mentee:Person {id: 5})
    CREATE (mentor)-[:MENTORS {focus_area: 'System Design', since: '2022-01-15'}]->(mentee)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person {id: 3}), (mentee:Person {id: 7})
    CREATE (mentor)-[:MENTORS {focus_area: 'Machine Learning', since: '2022-03-01'}]->(mentee)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person {id: 10}), (mentee:Person {id: 4})
    CREATE (mentor)-[:MENTORS {focus_area: 'Security Practices', since: '2021-06-01'}]->(mentee)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (mentor:Person {id: 6}), (mentee:Person {id: 14})
    CREATE (mentor)-[:MENTORS {focus_area: 'Database Design', since: '2023-09-01'}]->(mentee)
$$) AS (r agtype);

-- ============================================================
-- DEPENDS_ON EDGES (Project -> Project)
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Project {id: 101}), (p2:Project {id: 103})
    CREATE (p1)-[:DEPENDS_ON {dependency_type: 'infrastructure'}]->(p2)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Project {id: 102}), (p2:Project {id: 101})
    CREATE (p1)-[:DEPENDS_ON {dependency_type: 'data_source'}]->(p2)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Project {id: 104}), (p2:Project {id: 102})
    CREATE (p1)-[:DEPENDS_ON {dependency_type: 'data_pipeline'}]->(p2)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Project {id: 105}), (p2:Project {id: 107})
    CREATE (p1)-[:DEPENDS_ON {dependency_type: 'messaging'}]->(p2)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Project {id: 106}), (p2:Project {id: 103})
    CREATE (p1)-[:DEPENDS_ON {dependency_type: 'infrastructure'}]->(p2)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Project {id: 108}), (p2:Project {id: 101})
    CREATE (p1)-[:DEPENDS_ON {dependency_type: 'api_integration'}]->(p2)
$$) AS (r agtype);

-- ============================================================
-- BELONGS_TO EDGES (Person -> Team)
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 1}), (t:Team {id: 301})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Lead', since: '2023-06-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (t:Team {id: 301})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-06-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 6}), (t:Team {id: 301})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-06-15'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (t:Team {id: 301})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-07-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 3}), (t:Team {id: 302})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Lead', since: '2023-01-15'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 7}), (t:Team {id: 302})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-02-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 12}), (t:Team {id: 302})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-02-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 5}), (t:Team {id: 303})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-03-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 8}), (t:Team {id: 303})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Lead', since: '2023-03-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 9}), (t:Team {id: 303})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-04-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 10}), (t:Team {id: 304})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Lead', since: '2023-09-01'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 4}), (t:Team {id: 304})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2023-09-15'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 14}), (t:Team {id: 305})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2024-01-15'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 15}), (t:Team {id: 305})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Member', since: '2024-01-15'}]->(t)
$$) AS (r agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {id: 2}), (t:Team {id: 305})
    CREATE (p)-[:BELONGS_TO {role_in_team: 'Lead', since: '2024-01-01'}]->(t)
$$) AS (r agtype);

-- ============================================================
-- Verify edges were created
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    MATCH ()-[r:WORKS_ON]->() RETURN count(r) AS works_on_count
$$) AS (works_on_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH ()-[r:HAS_SKILL]->() RETURN count(r) AS has_skill_count
$$) AS (has_skill_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH ()-[r:MANAGES]->() RETURN count(r) AS manages_count
$$) AS (manages_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH ()-[r:MENTORS]->() RETURN count(r) AS mentors_count
$$) AS (mentors_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH ()-[r:DEPENDS_ON]->() RETURN count(r) AS depends_on_count
$$) AS (depends_on_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH ()-[r:BELONGS_TO]->() RETURN count(r) AS belongs_to_count
$$) AS (belongs_to_count agtype);
