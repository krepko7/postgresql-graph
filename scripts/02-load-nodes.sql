-- ============================================================
-- Script: 02-load-nodes.sql
-- Purpose: Load all node data into the techcorp graph
-- Prerequisites: Run 01-create-graph.sql first
-- ============================================================

-- Load the AGE extension and set search path
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- ============================================================
-- PEOPLE NODES
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 1, name: 'Alice Chen', title: 'Engineering Manager',
        department: 'Engineering', email: 'alice.chen@techcorp.com',
        hire_date: '2019-03-15', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 2, name: 'Bob Martinez', title: 'Senior Developer',
        department: 'Engineering', email: 'bob.martinez@techcorp.com',
        hire_date: '2020-01-10', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 3, name: 'Carol Williams', title: 'Data Scientist',
        department: 'Data Science', email: 'carol.williams@techcorp.com',
        hire_date: '2020-06-01', location: 'Portland'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 4, name: 'David Kim', title: 'DevOps Engineer',
        department: 'Infrastructure', email: 'david.kim@techcorp.com',
        hire_date: '2021-02-20', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 5, name: 'Eva Johnson', title: 'Frontend Developer',
        department: 'Engineering', email: 'eva.johnson@techcorp.com',
        hire_date: '2021-08-15', location: 'Remote'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 6, name: 'Frank Lee', title: 'Backend Developer',
        department: 'Engineering', email: 'frank.lee@techcorp.com',
        hire_date: '2020-11-01', location: 'Portland'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 7, name: 'Grace Patel', title: 'ML Engineer',
        department: 'Data Science', email: 'grace.patel@techcorp.com',
        hire_date: '2022-01-10', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 8, name: 'Henry Zhang', title: 'Product Manager',
        department: 'Product', email: 'henry.zhang@techcorp.com',
        hire_date: '2019-09-01', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 9, name: 'Iris Nakamura', title: 'UX Designer',
        department: 'Design', email: 'iris.nakamura@techcorp.com',
        hire_date: '2021-04-15', location: 'Remote'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 10, name: 'James Brown', title: 'Security Engineer',
        department: 'Infrastructure', email: 'james.brown@techcorp.com',
        hire_date: '2020-07-20', location: 'Portland'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 11, name: 'Karen Davis', title: 'QA Engineer',
        department: 'Engineering', email: 'karen.davis@techcorp.com',
        hire_date: '2022-03-01', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 12, name: 'Leo Torres', title: 'Data Engineer',
        department: 'Data Science', email: 'leo.torres@techcorp.com',
        hire_date: '2021-10-15', location: 'Remote'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 13, name: 'Maria Garcia', title: 'VP Engineering',
        department: 'Engineering', email: 'maria.garcia@techcorp.com',
        hire_date: '2018-01-15', location: 'Seattle'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 14, name: 'Nathan Wright', title: 'Junior Developer',
        department: 'Engineering', email: 'nathan.wright@techcorp.com',
        hire_date: '2023-06-01', location: 'Portland'
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Person {
        id: 15, name: 'Olivia Scott', title: 'Technical Writer',
        department: 'Product', email: 'olivia.scott@techcorp.com',
        hire_date: '2022-09-01', location: 'Remote'
    })
$$) AS (v agtype);

-- ============================================================
-- PROJECT NODES
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 101, name: 'Phoenix', description: 'Next-gen microservices platform',
        status: 'active', start_date: '2024-01-15',
        technology: 'Rust/Go', budget: 500000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 102, name: 'Atlas', description: 'Customer data analytics dashboard',
        status: 'active', start_date: '2024-03-01',
        technology: 'Python/React', budget: 350000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 103, name: 'Titan', description: 'Infrastructure automation framework',
        status: 'active', start_date: '2023-11-01',
        technology: 'Terraform/Go', budget: 280000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 104, name: 'Nova', description: 'ML recommendation engine',
        status: 'planning', start_date: '2024-06-01',
        technology: 'Python/PyTorch', budget: 420000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 105, name: 'Horizon', description: 'Mobile app redesign',
        status: 'active', start_date: '2024-02-15',
        technology: 'React Native', budget: 300000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 106, name: 'Sentinel', description: 'Security monitoring platform',
        status: 'active', start_date: '2023-09-01',
        technology: 'Rust/Kafka', budget: 380000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 107, name: 'Echo', description: 'Real-time messaging system',
        status: 'completed', start_date: '2023-03-01',
        technology: 'Node.js/Redis', budget: 250000
    })
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Project {
        id: 108, name: 'Compass', description: 'Internal developer portal',
        status: 'active', start_date: '2024-04-01',
        technology: 'TypeScript/Next.js', budget: 200000
    })
$$) AS (v agtype);

-- ============================================================
-- SKILL NODES
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 201, name: 'Python', category: 'Programming Language', level_description: 'General-purpose programming'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 202, name: 'Rust', category: 'Programming Language', level_description: 'Systems programming'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 203, name: 'Go', category: 'Programming Language', level_description: 'Cloud-native development'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 204, name: 'JavaScript', category: 'Programming Language', level_description: 'Web development'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 205, name: 'TypeScript', category: 'Programming Language', level_description: 'Typed web development'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 206, name: 'React', category: 'Framework', level_description: 'Frontend UI library'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 207, name: 'Node.js', category: 'Runtime', level_description: 'Server-side JavaScript'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 208, name: 'PostgreSQL', category: 'Database', level_description: 'Relational database'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 209, name: 'Kubernetes', category: 'Infrastructure', level_description: 'Container orchestration'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 210, name: 'Terraform', category: 'Infrastructure', level_description: 'Infrastructure as code'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 211, name: 'Machine Learning', category: 'Domain', level_description: 'AI/ML techniques'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 212, name: 'Docker', category: 'Infrastructure', level_description: 'Containerization'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 213, name: 'GraphQL', category: 'API', level_description: 'Query language for APIs'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 214, name: 'Kafka', category: 'Infrastructure', level_description: 'Event streaming'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Skill {id: 215, name: 'Redis', category: 'Database', level_description: 'In-memory data store'})
$$) AS (v agtype);

-- ============================================================
-- TEAM NODES
-- ============================================================

SELECT * FROM cypher('techcorp', $$
    CREATE (:Team {id: 301, name: 'Platform Team', focus_area: 'Core infrastructure and services', formed_date: '2023-06-01'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Team {id: 302, name: 'Data Team', focus_area: 'Analytics and ML', formed_date: '2023-01-15'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Team {id: 303, name: 'Product Team', focus_area: 'User-facing features', formed_date: '2023-03-01'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Team {id: 304, name: 'Security Team', focus_area: 'Security and compliance', formed_date: '2023-09-01'})
$$) AS (v agtype);

SELECT * FROM cypher('techcorp', $$
    CREATE (:Team {id: 305, name: 'DevEx Team', focus_area: 'Developer experience and tooling', formed_date: '2024-01-01'})
$$) AS (v agtype);

-- ============================================================
-- Verify nodes were created
-- ============================================================

-- Count all nodes by label
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person) RETURN count(p) AS person_count
$$) AS (person_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (p:Project) RETURN count(p) AS project_count
$$) AS (project_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (s:Skill) RETURN count(s) AS skill_count
$$) AS (skill_count agtype);

SELECT * FROM cypher('techcorp', $$
    MATCH (t:Team) RETURN count(t) AS team_count
$$) AS (team_count agtype);
