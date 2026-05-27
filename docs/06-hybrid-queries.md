# Step 6: Hybrid SQL/Cypher Queries

## Why Hybrid Queries?

Apache AGE's killer feature is the ability to **combine graph traversals with relational SQL**. This lets you:

- Join graph results with relational tables
- Apply SQL aggregation, window functions, and CTEs to graph data
- Create materialized views from graph queries
- Use UNION to combine multiple graph query results

## How Hybrid Queries Work

The `cypher()` function returns a table, which SQL can use like any subquery:

```sql
-- Cypher result used as a SQL subquery
SELECT column1, COUNT(*)
FROM cypher('graph_name', $$
    MATCH (n)-[r]->(m)
    RETURN n.prop, m.prop
$$) AS (column1 agtype, column2 agtype)
GROUP BY column1;
```

## Session Setup

```sql
SET search_path = ag_catalog, "$user", public;
```

Open `queries/hybrid-queries.sql` in VS Code and follow along.

---

## Pattern 1: SQL Filtering on Cypher Results

Use SQL WHERE/LIKE on graph query output:

```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    RETURN p.name, p.title, proj.name, w.role
$$) AS (person_name agtype, person_title agtype, project_name agtype, role agtype)
WHERE person_name::text LIKE '%Martinez%';
```

---

## Pattern 2: SQL Aggregation on Cypher Results

```sql
SELECT project_name, COUNT(*) AS member_count, SUM(hours::int) AS total_hours
FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    RETURN proj.name, w.hours_per_week
$$) AS (project_name agtype, hours agtype)
GROUP BY project_name
ORDER BY total_hours DESC;
```

---

## Pattern 3: Joining Graph + Relational Data

Create a relational table and join it with graph results:

```sql
-- Create a relational table
CREATE TABLE IF NOT EXISTS project_budget_tracking (
    project_name TEXT PRIMARY KEY,
    q1_spend NUMERIC,
    q2_spend NUMERIC,
    remaining_budget NUMERIC
);

INSERT INTO project_budget_tracking VALUES
    ('Phoenix', 125000, 130000, 245000),
    ('Atlas', 80000, 95000, 175000),
    ('Titan', 70000, 72000, 138000)
ON CONFLICT (project_name) DO NOTHING;

-- Join graph query with relational table
SELECT
    g.project_name,
    g.team_size,
    b.remaining_budget
FROM (
    SELECT project_name, team_count
    FROM cypher('techcorp', $$
        MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
        RETURN proj.name, count(p)
    $$) AS (project_name agtype, team_count agtype)
) AS g(project_name, team_size),
project_budget_tracking b
WHERE b.project_name = g.project_name::text;
```

---

## Pattern 4: Window Functions

```sql
SELECT
    person_name,
    skill_count,
    RANK() OVER (ORDER BY skill_count::int DESC) AS skill_rank
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
    RETURN p.name, count(s)
$$) AS (person_name agtype, skill_count agtype);
```

---

## Pattern 5: CTEs (Common Table Expressions)

```sql
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
```

---

## Pattern 6: UNION of Multiple Graph Queries

```sql
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
```

---

## Pattern 7: Materialized Views

Cache graph query results for fast repeated access:

```sql
CREATE MATERIALIZED VIEW IF NOT EXISTS team_summary AS
SELECT team_name, member_count
FROM cypher('techcorp', $$
    MATCH (p:Person)-[:BELONGS_TO]->(t:Team)
    RETURN t.name, count(p)
$$) AS (team_name agtype, member_count agtype);

-- Fast query from cache
SELECT * FROM team_summary;

-- Refresh when data changes
REFRESH MATERIALIZED VIEW team_summary;
```

---

## Real-World Use Cases

### 1. Management Span Analysis

```sql
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
```

### 2. Cross-Team Collaboration Finder

```sql
SELECT p1_name, p2_name, project_name, t1_name, t2_name
FROM cypher('techcorp', $$
    MATCH (p1:Person)-[:WORKS_ON]->(proj:Project)<-[:WORKS_ON]-(p2:Person)
    MATCH (p1)-[:BELONGS_TO]->(t1:Team)
    MATCH (p2)-[:BELONGS_TO]->(t2:Team)
    WHERE p1.id < p2.id AND t1 <> t2
    RETURN p1.name, p2.name, proj.name, t1.name, t2.name
$$) AS (p1_name agtype, p2_name agtype, project_name agtype, t1_name agtype, t2_name agtype);
```

### 3. Project Risk Assessment

```sql
WITH project_deps AS (
    SELECT project_name, dep_count
    FROM cypher('techcorp', $$
        MATCH (p:Project)-[:DEPENDS_ON]->(d:Project)
        RETURN p.name, count(d)
    $$) AS (project_name agtype, dep_count agtype)
),
project_team AS (
    SELECT project_name, team_size
    FROM cypher('techcorp', $$
        MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
        RETURN proj.name, count(p)
    $$) AS (project_name agtype, team_size agtype)
)
SELECT
    pt.project_name,
    pt.team_size,
    COALESCE(pd.dep_count, '0'::agtype) AS dependencies,
    CASE
        WHEN pd.dep_count::int > 1 AND pt.team_size::int < 3
        THEN 'HIGH RISK'
        WHEN pd.dep_count::int > 0
        THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_level
FROM project_team pt
LEFT JOIN project_deps pd ON pt.project_name = pd.project_name
ORDER BY risk_level;
```

---

## Exercises

1. **Create a relational table** with quarterly targets per team and join it with graph data to find teams above/below target.
2. **Build a CTE** that finds the "critical path" — people who are single points of failure for projects.
3. **Create a materialized view** showing each person's total workload across all projects.

---

**Next:** [Push to GitHub →](07-github-setup.md)
