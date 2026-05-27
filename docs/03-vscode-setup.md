# Step 3: Configure VS Code PostgreSQL Extension

## Install the Extension

1. Open VS Code
2. Go to **Extensions** (Ctrl+Shift+X)
3. Search for **"PostgreSQL"** by Microsoft
4. Click **Install**

> The extension ID is: `ms-ossdata.vscode-postgresql`
>
> Alternative: You can also use **"PostgreSQL Explorer"** by Chris Kolkman (`ckolkman.vscode-postgres`)

## Connect to Azure PostgreSQL

### Option A: Using the PostgreSQL Extension by Microsoft

1. Open the **Command Palette** (Ctrl+Shift+P)
2. Type: `PostgreSQL: New Query`
3. If no connections exist, it will prompt you to create one
4. Enter the connection details:

| Field    | Value                                       |
| -------- | ------------------------------------------- |
| Host     | `<SERVER_NAME>.postgres.database.azure.com` |
| Port     | `5432`                                      |
| Database | `graphworkshop`                             |
| Username | `graphadmin`                                |
| Password | `<your-password>`                           |
| SSL      | `Require`                                   |

5. Save the connection profile with a name like **"Graph Workshop"**

### Option B: Using Connection String

1. Click the **PostgreSQL** icon in the Activity Bar (left sidebar)
2. Click **"+"** to add a new connection
3. Use the connection string format:

```
host=<SERVER_NAME>.postgres.database.azure.com port=5432 dbname=graphworkshop user=graphadmin password=<your-password> sslmode=require
```

## Running Queries

### Execute a Query

1. Open any `.sql` file from this workshop (e.g., `scripts/01-create-graph.sql`)
2. Select the SQL statement(s) you want to run
3. Right-click and select **"Execute Query"** or press **Ctrl+Shift+E**
4. Results appear in the **Results** panel at the bottom

### Important: Session Setup for AGE

Every time you open a new query connection, first run:

```sql
SET search_path = ag_catalog, "$user", public;
```

> **Tip:** Keep these two lines at the top of every `.sql` file in this workshop.

### Running Multiple Statements

- **Select specific statements** and execute them one at a time
- For the load scripts, run statements sequentially (top to bottom)
- Some queries depend on previous ones being executed first

## VS Code Workspace Settings

Create a workspace settings file for better SQL editing:

### `.vscode/settings.json`

```json
{
  "files.associations": {
    "*.sql": "sql"
  },
  "[sql]": {
    "editor.tabSize": 4,
    "editor.wordWrap": "on"
  },
  "pgsql.connections": [
    {
      "host": "<SERVER_NAME>.postgres.database.azure.com",
      "port": 5432,
      "database": "graphworkshop",
      "user": "graphadmin",
      "ssl": "require"
    }
  ]
}
```

## Tips for the Workshop

1. **Execute step by step** — Don't run entire files at once; execute each `SELECT * FROM cypher(...)` statement individually to see results.

2. **Check for errors** — If you get a `function cypher does not exist` error, confirm AGE is preloaded on the server and run the `SET search_path` command again.

3. **Multiple result sets** — The verification queries at the end of load scripts help you confirm data was loaded correctly.

4. **Reconnection** — If your connection times out, reconnect and re-run the session setup commands.

## Recommended VS Code Extensions

| Extension              | Purpose                                   |
| ---------------------- | ----------------------------------------- |
| PostgreSQL (Microsoft) | Query execution and connection management |
| SQL Formatter          | Format SQL for readability                |
| Rainbow CSV            | View CSV data files with color coding     |

---

**Next:** [Load Sample Data →](04-load-data.md)
