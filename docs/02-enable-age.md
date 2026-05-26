# Step 2: Enable Apache AGE Extension

## About Apache AGE

**Apache AGE (A Graph Extension)** is a PostgreSQL extension that adds graph database capabilities. It allows you to:

- Store and query graph data alongside relational data
- Use the Cypher query language (same as Neo4j)
- Combine SQL and Cypher in hybrid queries

## Enable AGE on Azure PostgreSQL Flexible Server

### 1. Allow the AGE Extension

Azure PostgreSQL Flexible Server requires extensions to be allowlisted before they can be installed.

```bash
az postgres flexible-server parameter set \
    --resource-group $RESOURCE_GROUP \
    --server-name $SERVER_NAME \
    --name azure.extensions \
    --value age
```

> **Note:** If you already have other extensions enabled, append `age` to the existing comma-separated list:
>
> ```bash
> az postgres flexible-server parameter show \
>     --resource-group $RESOURCE_GROUP \
>     --server-name $SERVER_NAME \
>     --name azure.extensions
> ```

### 2. Configure Shared Preload Libraries

AGE requires being loaded as a shared preload library:

```bash
az postgres flexible-server parameter set \
    --resource-group $RESOURCE_GROUP \
    --server-name $SERVER_NAME \
    --name shared_preload_libraries \
    --value age
```

> **Important:** This requires a server restart. The parameter change will trigger an automatic restart.

### 3. Restart the Server (if needed)

```bash
az postgres flexible-server restart \
    --resource-group $RESOURCE_GROUP \
    --name $SERVER_NAME
```

Wait for the server to come back online (1-2 minutes).

### 4. Install the Extension

Connect to your database and run:

```sql
-- Connect to the graphworkshop database
CREATE EXTENSION IF NOT EXISTS age;
```

### 5. Verify Installation

```sql
-- Check AGE is installed
SELECT * FROM pg_extension WHERE extname = 'age';

-- Set the search path to include ag_catalog
SET search_path = ag_catalog, "$user", public;

-- Verify AGE functions are available
SELECT * FROM ag_catalog.ag_graph;
```

## Understanding AGE Concepts

### Graph Storage

AGE stores graphs in PostgreSQL using:

- **ag_catalog schema** — Contains AGE metadata tables
- **Graph-specific schemas** — Each graph gets its own schema (e.g., `techcorp`)
- **Label tables** — Each node/edge label becomes a table within the graph schema

### Session Setup

Every time you open a new connection, you need to:

```sql
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
```

### Cypher in SQL

AGE uses a wrapper function to execute Cypher:

```sql
SELECT * FROM cypher('graph_name', $$
    -- Your Cypher query here
    MATCH (n) RETURN n
$$) AS (result agtype);
```

Key points:

- `'graph_name'` — The name of your graph
- `$$...$$` — Dollar-quoted string containing Cypher
- `AS (columns agtype)` — Column definitions for the result set
- `agtype` — AGE's data type for graph elements

## Troubleshooting

### "extension 'age' is not available"

Ensure you've allowlisted the extension and restarted:

```bash
az postgres flexible-server parameter show \
    --resource-group $RESOURCE_GROUP \
    --server-name $SERVER_NAME \
    --name azure.extensions
```

### "could not load library age"

Ensure `shared_preload_libraries` includes `age`:

```bash
az postgres flexible-server parameter show \
    --resource-group $RESOURCE_GROUP \
    --server-name $SERVER_NAME \
    --name shared_preload_libraries
```

### "function cypher does not exist"

Make sure to run at the start of every session:

```sql
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
```

---

**Next:** [Configure VS Code PostgreSQL Extension →](03-vscode-setup.md)
