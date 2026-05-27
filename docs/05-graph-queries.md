# Step 5: Graph Queries with Cypher

## Introduction to Cypher

Cypher is a declarative graph query language that uses ASCII-art patterns to describe graph patterns:

- **Nodes:** `(variable:Label {property: value})`
- **Relationships:** `-[:TYPE {property: value}]->`
- **Paths:** `(a)-[:REL]->(b)-[:REL]->(c)`

In Apache AGE, Cypher is embedded in SQL:

```sql
SELECT * FROM cypher('graph_name', $$
    CYPHER QUERY HERE
$$) AS (column1 agtype, column2 agtype);
```

## Session Setup

Always run first:

```sql
SET search_path = ag_catalog, "$user", public;
```

## Query Categories

Open `queries/cypher-queries.sql` in VS Code and follow along.

---

### Basic Node Queries

**Get all people:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)
    RETURN p.name, p.title, p.department
    ORDER BY p.name
$$) AS (name agtype, title agtype, department agtype);
```

**Filter by property:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (proj:Project {status: 'active'})
    RETURN proj.name, proj.technology, proj.budget
    ORDER BY proj.budget DESC
$$) AS (name agtype, technology agtype, budget agtype);
```

---

### Relationship Traversal

**Find who works on Phoenix:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project {name: 'Phoenix'})
    RETURN p.name, w.role, w.hours_per_week
    ORDER BY w.hours_per_week DESC
$$) AS (name agtype, role agtype, hours agtype);
```

**Find someone's skills:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person {name: 'Alice Chen'})-[h:HAS_SKILL]->(s:Skill)
    RETURN s.name, h.proficiency, h.years_experience
    ORDER BY h.years_experience DESC
$$) AS (skill agtype, proficiency agtype, years agtype);
```

---

### Multi-Hop Queries

**Management chain (2 levels):**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (vp:Person)-[:MANAGES]->(mgr:Person)-[:MANAGES]->(emp:Person)
    RETURN vp.name AS vp, mgr.name AS manager, emp.name AS employee
$$) AS (vp agtype, manager agtype, employee agtype);
```

**Variable-length paths (project dependencies):**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH path = (p1:Project)-[:DEPENDS_ON*1..3]->(p2:Project)
    RETURN p1.name AS project, p2.name AS depends_on
$$) AS (project agtype, depends_on agtype);
```

---

### Pattern Matching

**People who share skills:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Person {name: 'Bob Martinez'})-[:HAS_SKILL]->(s:Skill)<-[:HAS_SKILL]-(p2:Person)
    WHERE p1 <> p2
    RETURN DISTINCT p2.name, s.name AS shared_skill
    ORDER BY p2.name
$$) AS (person agtype, shared_skill agtype);
```

**Teammates (connected through a team):**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p1:Person)-[:BELONGS_TO]->(t:Team)<-[:BELONGS_TO]-(p2:Person)
    WHERE p1.id < p2.id
    RETURN p1.name, p2.name, t.name AS team
    ORDER BY t.name
$$) AS (person1 agtype, person2 agtype, team agtype);
```

---

### Aggregation

**Team size per project:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
    RETURN proj.name, count(p) AS team_size
    ORDER BY team_size DESC
$$) AS (project agtype, team_size agtype);
```

**Most popular skills:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
    RETURN s.name, count(p) AS people_count
    ORDER BY people_count DESC
$$) AS (skill agtype, people_count agtype);
```

---

### Advanced Patterns

**People working on multiple projects:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[:WORKS_ON]->(proj:Project)
    WITH p, count(proj) AS project_count
    WHERE project_count > 1
    RETURN p.name, project_count
    ORDER BY project_count DESC
$$) AS (name agtype, project_count agtype);
```

**Shortest path:**
```sql
SELECT * FROM cypher('techcorp', $$
    MATCH path = shortestPath(
        (p1:Person {name: 'Nathan Wright'})-[*]-(p2:Person {name: 'Maria Garcia'})
    )
    RETURN length(path) AS path_length
$$) AS (path_length agtype);
```

---

## Exercises

Try writing queries for these scenarios:

1. **Find all people in Portland who work on active projects**
2. **Find which skills are needed by projects using Python**
3. **Who is Nathan Wright's mentor's manager?**
4. **Which team has the most diverse skill set?**
5. **Find people who could potentially mentor others in Kubernetes**

---

**Next:** [Advanced Hybrid Queries →](06-hybrid-queries.md)
