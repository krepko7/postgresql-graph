# Streamlit Graph Workshop App

A Streamlit frontend for testing and comparing SQL, Cypher, and Hybrid queries against the PostgreSQL AGE graph database.

## Setup

### 1. Install Dependencies

```bash
cd app
pip install -r requirements.txt
```

### 2. Configure Database Connection

Copy the example environment file and fill in your Azure PostgreSQL credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```
PG_HOST=your-server.postgres.database.azure.com
PG_PORT=5432
PG_DATABASE=graphworkshop
PG_USER=graphadmin
PG_PASSWORD=your-password-here
PG_SSLMODE=require
```

> **Note:** You can also enter credentials directly in the app sidebar.

### 3. Run the App

```bash
streamlit run app.py
```

The app will open in your browser at `http://localhost:8501`.

## Features

### 📊 Compare Queries Tab
- Browse pre-built queries organized by category
- See the same query expressed in SQL, Cypher, and Hybrid side-by-side
- Execute each version and compare performance (execution time)
- Understand when to use each approach

### ✏️ Custom Query Tab
- Write and execute your own Cypher or hybrid queries
- Quick templates for common patterns
- Multi-statement support

### 📚 Reference Tab
- Cypher syntax quick reference
- AGE SQL wrapper patterns
- Hybrid query patterns
- Graph data model diagram

## Query Categories

| Category | Queries | Focus |
|----------|---------|-------|
| Basic Lookups | 3 | Node filtering, counting |
| Relationship Traversal | 3 | Pattern matching, variable-length paths |
| Multi-Hop & Pattern Matching | 3 | Complex patterns, cross-entity queries |
| Aggregation & Analytics | 3 | Counting, ranking, gap analysis |

## Screenshots

The app provides:
- Side-by-side code comparison with syntax highlighting
- Execution timing metrics
- DataFrame result display
- Performance comparison across query types

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Connection failed" | Check host, credentials, and firewall rules |
| "AGE init failed" | Ensure AGE extension is installed and `shared_preload_libraries` includes `age` |
| "function cypher does not exist" | Click Reconnect — AGE needs `LOAD` per session |
| Timeout errors | Azure PG may need firewall rule for your IP |
