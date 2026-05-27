# Step 4: Load Sample Data

## Overview

The workshop uses a **technology company organizational graph** with:
- **15 People** (employees in various roles)
- **8 Projects** (software projects)
- **15 Skills** (technical skills)
- **5 Teams** (organizational teams)
- **6 Relationship types** connecting them

## Loading Order

Execute the scripts in this order:

1. `scripts/01-create-graph.sql` — Creates the graph schema
2. `scripts/02-load-nodes.sql` — Loads all nodes (People, Projects, Skills, Teams)
3. `scripts/03-load-edges.sql` — Loads all relationships

## Step-by-Step Instructions

### 1. Create the Graph

Open `scripts/01-create-graph.sql` in VS Code and execute:

```sql
SET search_path = ag_catalog, "$user", public;

-- Create the graph
SELECT create_graph('techcorp');
```

Expected output: One row confirming graph creation.

### 2. Load Nodes

Open `scripts/02-load-nodes.sql` in VS Code.

**Execute each CREATE statement one at a time**, or select all Person nodes and execute together.

After all nodes are loaded, run the verification queries at the bottom:

```sql
-- Expected counts:
-- person_count: 15
-- project_count: 8
-- skill_count: 15
-- team_count: 5
```

### 3. Load Edges

Open `scripts/03-load-edges.sql` in VS Code.

Execute the edge creation statements. After loading, verify:

```sql
-- Expected counts:
-- works_on_count: 19
-- has_skill_count: 37
-- manages_count: 12
-- mentors_count: 5
-- depends_on_count: 6
-- belongs_to_count: 15
```

## Data Model Summary

### Node Types

| Label | Count | Key Properties |
|-------|-------|---------------|
| Person | 15 | id, name, title, department, location |
| Project | 8 | id, name, status, technology, budget |
| Skill | 15 | id, name, category |
| Team | 5 | id, name, focus_area |

### Edge Types

| Type | Count | From → To | Key Properties |
|------|-------|-----------|---------------|
| WORKS_ON | 19 | Person → Project | role, hours_per_week |
| HAS_SKILL | 37 | Person → Skill | proficiency, years_experience |
| MANAGES | 12 | Person → Person | since |
| MENTORS | 5 | Person → Person | focus_area |
| DEPENDS_ON | 6 | Project → Project | dependency_type |
| BELONGS_TO | 15 | Person → Team | role_in_team |

## Troubleshooting

### "graph already exists"

If you need to reset, run the cleanup script first:
```sql
SET search_path = ag_catalog, "$user", public;
SELECT drop_graph('techcorp', true);
```
Then start from step 1.

### "label does not exist" on edge creation

Make sure all nodes are loaded before creating edges. Re-run `02-load-nodes.sql`.

### Counts don't match

Re-run the load scripts. If duplicates exist, drop and recreate the graph.

## Quick Verification Query

After all data is loaded, run this to see a sample of the graph:

```sql
SET search_path = ag_catalog, "$user", public;

-- Show 5 people and their projects
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)-[w:WORKS_ON]->(proj:Project)
    RETURN p.name, proj.name, w.role
    LIMIT 10
$$) AS (person agtype, project agtype, role agtype);
```

---

**Next:** [Run Graph Queries →](05-graph-queries.md)
