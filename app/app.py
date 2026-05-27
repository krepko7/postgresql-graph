"""
PostgreSQL Graph Workshop — Streamlit App
Compare pure SQL, Cypher, and Hybrid SQL/Cypher queries using Apache AGE.
"""

import streamlit as st
import psycopg2
import pandas as pd
import time
import os
from dotenv import load_dotenv
from queries import QUERY_CATEGORIES, CUSTOM_QUERY_TEMPLATE

load_dotenv()

# ============================================================
# Page Configuration
# ============================================================

st.set_page_config(
    page_title="PostgreSQL Graph Workshop",
    page_icon="🔗",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.title("🔗 PostgreSQL Graph Workshop with Apache AGE")
st.caption("Compare SQL, Cypher, and Hybrid queries on a graph database")

# ============================================================
# Database Connection
# ============================================================


def get_connection_params():
    """Get connection parameters from sidebar or environment."""
    with st.sidebar:
        st.header("🔌 Database Connection")

        host = st.text_input("Host", value=os.getenv("PG_HOST", ""), type="default")
        port = st.number_input("Port", value=int(os.getenv("PG_PORT", 5432)), min_value=1, max_value=65535)
        database = st.text_input("Database", value=os.getenv("PG_DATABASE", "graphworkshop"))
        user = st.text_input("Username", value=os.getenv("PG_USER", ""))
        password = st.text_input("Password", value=os.getenv("PG_PASSWORD", ""), type="password")
        sslmode = st.selectbox("SSL Mode", ["require", "prefer", "disable"], index=0)

    return {
        "host": host,
        "port": port,
        "dbname": database,
        "user": user,
        "password": password,
        "sslmode": sslmode,
    }


@st.cache_resource
def get_connection(_params_tuple):
    """Create a database connection (cached)."""
    params = dict(zip(["host", "port", "dbname", "user", "password", "sslmode"], _params_tuple))
    try:
        conn = psycopg2.connect(**params)
        conn.autocommit = True
        return conn
    except Exception as e:
        return None


def init_age_session(conn):
    """Initialize AGE for the current session."""
    try:
        cur = conn.cursor()
        cur.execute("SET search_path = ag_catalog, \"$user\", public;")
        cur.close()
        return True
    except Exception as e:
        st.error(f"Failed to initialize AGE: {e}")
        conn.rollback()
        return False


def execute_query(conn, query):
    """Execute a query and return results as DataFrame with timing."""
    try:
        start_time = time.time()
        cur = conn.cursor()
        cur.execute(query)
        elapsed = time.time() - start_time

        if cur.description:
            columns = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
            df = pd.DataFrame(rows, columns=columns)
            cur.close()
            return df, elapsed, None
        else:
            cur.close()
            return pd.DataFrame(), elapsed, None
    except Exception as e:
        conn.rollback()
        # Re-init AGE session after error
        init_age_session(conn)
        return None, 0, str(e)


# ============================================================
# Sidebar
# ============================================================

params = get_connection_params()

with st.sidebar:
    st.divider()
    connect_btn = st.button("🔗 Connect", type="primary", use_container_width=True)

    if connect_btn or "connected" in st.session_state:
        params_tuple = (
            params["host"], params["port"], params["dbname"],
            params["user"], params["password"], params["sslmode"]
        )

        if params["host"] and params["user"]:
            conn = get_connection(params_tuple)
            if conn and not conn.closed:
                if init_age_session(conn):
                    st.session_state["connected"] = True
                    st.success("✅ Connected")
                else:
                    st.error("Connected but AGE init failed")
            else:
                st.error("❌ Connection failed. Check credentials.")
        else:
            st.warning("Please fill in host and username")

    st.divider()
    st.header("📖 About")
    st.markdown("""
    This app demonstrates the differences between:
    - **Pure SQL** — querying AGE internal tables directly
    - **Cypher** — using graph pattern matching via AGE
    - **Hybrid** — combining Cypher traversals with SQL analytics

    The graph models a tech company with People, Projects, Skills, and Teams.
    """)

# ============================================================
# Main Content — Tabs
# ============================================================

tab_compare, tab_custom, tab_reference = st.tabs([
    "📊 Compare Queries", "✏️ Custom Query", "📚 Reference"
])

# ------------------------------------------------------------
# Tab 1: Compare Queries
# ------------------------------------------------------------

with tab_compare:
    st.header("Compare Query Approaches")
    st.markdown("Select a query to see it expressed in SQL, Cypher, and Hybrid SQL/Cypher side by side.")

    col_cat, col_query = st.columns([1, 2])
    with col_cat:
        category = st.selectbox("Category", list(QUERY_CATEGORIES.keys()))
    with col_query:
        queries_in_cat = QUERY_CATEGORIES[category]
        query_name = st.selectbox("Query", list(queries_in_cat.keys()))

    selected = queries_in_cat[query_name]

    # Description
    st.info(f"💡 **{query_name}** — {selected['description']}")

    # Display queries side by side
    available_types = []
    if selected.get("sql"):
        available_types.append("SQL")
    if selected.get("cypher"):
        available_types.append("Cypher")
    if selected.get("hybrid"):
        available_types.append("Hybrid")

    query_cols = st.columns(len(available_types))

    for i, qtype in enumerate(available_types):
        with query_cols[i]:
            key = qtype.lower()
            st.subheader(f"{'📋' if key == 'sql' else '🔄' if key == 'cypher' else '🔀'} {qtype}")
            st.code(selected[key].strip(), language="sql")

    # Execute buttons
    st.divider()
    st.subheader("▶️ Execute & Compare")

    if "connected" not in st.session_state:
        st.warning("⚠️ Connect to the database first (use the sidebar)")
    else:
        exec_cols = st.columns(len(available_types))
        for i, qtype in enumerate(available_types):
            with exec_cols[i]:
                key = qtype.lower()
                if st.button(f"Run {qtype}", key=f"run_{key}_{query_name}", use_container_width=True):
                    query_text = selected[key]
                    # For cypher/hybrid queries, AGE is already loaded
                    df, elapsed, error = execute_query(conn, query_text)
                    if error:
                        st.error(f"Error: {error}")
                    elif df is not None:
                        st.metric("Execution Time", f"{elapsed*1000:.1f} ms")
                        st.dataframe(df, use_container_width=True)
                    else:
                        st.info("Query executed (no results)")

        # Run all button
        st.divider()
        if st.button("🚀 Run All & Compare Performance", type="primary", use_container_width=True):
            results = {}
            for qtype in available_types:
                key = qtype.lower()
                df, elapsed, error = execute_query(conn, selected[key])
                results[qtype] = {"df": df, "time": elapsed, "error": error}

            # Performance comparison
            perf_cols = st.columns(len(available_types))
            for i, qtype in enumerate(available_types):
                with perf_cols[i]:
                    r = results[qtype]
                    if r["error"]:
                        st.error(f"{qtype}: {r['error']}")
                    else:
                        st.metric(
                            f"{qtype} Time",
                            f"{r['time']*1000:.1f} ms",
                        )
                        if r["df"] is not None and not r["df"].empty:
                            st.dataframe(r["df"], use_container_width=True, height=300)

# ------------------------------------------------------------
# Tab 2: Custom Query
# ------------------------------------------------------------

with tab_custom:
    st.header("✏️ Custom Query Editor")
    st.markdown("Write and execute your own Cypher or hybrid queries.")

    custom_query = st.text_area(
        "Enter your query:",
        value=CUSTOM_QUERY_TEMPLATE,
        height=300,
        key="custom_query",
    )

    col_run, col_clear = st.columns([1, 4])
    with col_run:
        run_custom = st.button("▶️ Execute", type="primary", key="run_custom")

    if run_custom:
        if "connected" not in st.session_state:
            st.warning("⚠️ Connect to the database first")
        else:
            # Split and execute (handle multi-statement)
            statements = [s.strip() for s in custom_query.split(";") if s.strip()]
            last_df = None
            total_time = 0

            for stmt in statements:
                if not stmt:
                    continue
                df, elapsed, error = execute_query(conn, stmt + ";")
                total_time += elapsed
                if error:
                    st.error(f"Error: {error}")
                    break
                if df is not None and not df.empty:
                    last_df = df

            if last_df is not None:
                st.metric("Total Execution Time", f"{total_time*1000:.1f} ms")
                st.dataframe(last_df, use_container_width=True)
            elif not error:
                st.success(f"Query executed successfully ({total_time*1000:.1f} ms)")

    # Quick templates
    st.divider()
    st.subheader("📝 Quick Templates")

    template_col1, template_col2 = st.columns(2)

    with template_col1:
        st.markdown("**Cypher Patterns**")
        st.code("""-- Match all nodes of a type
SELECT * FROM cypher('techcorp', $$
    MATCH (p:Person)
    RETURN p.name, p.title
    LIMIT 10
$$) AS (name agtype, title agtype);""", language="sql")

        st.code("""-- Traverse relationships
SELECT * FROM cypher('techcorp', $$
    MATCH (a:Person)-[r:WORKS_ON]->(b:Project)
    RETURN a.name, type(r), b.name
    LIMIT 10
$$) AS (person agtype, rel agtype, project agtype);""", language="sql")

    with template_col2:
        st.markdown("**Hybrid Patterns**")
        st.code("""-- CTE + Cypher
WITH graph_data AS (
    SELECT person, skill
    FROM cypher('techcorp', $$
        MATCH (p:Person)-[:HAS_SKILL]->(s:Skill)
        RETURN p.name, s.name
    $$) AS (person agtype, skill agtype)
)
SELECT person, COUNT(*) AS skills
FROM graph_data
GROUP BY person
ORDER BY skills DESC;""", language="sql")

        st.code("""-- Window functions on graph results
SELECT person, connections,
    RANK() OVER (ORDER BY connections::int DESC)
FROM cypher('techcorp', $$
    MATCH (p:Person)-[r]->()
    RETURN p.name, count(r)
$$) AS (person agtype, connections agtype);""", language="sql")

# ------------------------------------------------------------
# Tab 3: Reference
# ------------------------------------------------------------

with tab_reference:
    st.header("📚 Quick Reference")

    ref_col1, ref_col2 = st.columns(2)

    with ref_col1:
        st.subheader("Cypher Syntax")
        st.markdown("""
| Pattern | Meaning |
|---------|---------|
| `(n:Label)` | Node with label |
| `(n {prop: val})` | Node with property |
| `-[r:TYPE]->` | Directed relationship |
| `-[r:TYPE*1..3]->` | Variable-length path |
| `MATCH` | Find pattern |
| `CREATE` | Create nodes/edges |
| `SET n.prop = val` | Update property |
| `DELETE r` | Delete relationship |
| `DETACH DELETE n` | Delete node + edges |
| `WITH` | Pipeline results |
| `WHERE` | Filter |
| `RETURN` | Output |
| `ORDER BY` | Sort |
| `LIMIT` | Restrict rows |
| `count()`, `sum()` | Aggregation |
| `collect()` | Collect into list |
| `shortestPath()` | Shortest path |
        """)

    with ref_col2:
        st.subheader("AGE SQL Wrapper")
        st.markdown("""
```sql
-- Basic structure
SELECT * FROM cypher('graph_name', $$
    CYPHER_QUERY
$$) AS (col1 agtype, col2 agtype);

-- Session setup (every connection)

SET search_path = ag_catalog, "$user", public;

-- Create a graph
SELECT create_graph('name');

-- Drop a graph
SELECT drop_graph('name', true);
```
        """)

        st.subheader("Hybrid Patterns")
        st.markdown("""
| Pattern | Use Case |
|---------|----------|
| `WHERE col::text LIKE '%x%'` | SQL filter on Cypher |
| `GROUP BY` + `COUNT` | SQL aggregation |
| `RANK() OVER (...)` | Window functions |
| `WITH cte AS (...)` | CTEs with Cypher |
| `JOIN relational_table` | Mix graph + tables |
| `CREATE MATERIALIZED VIEW` | Cache graph results |
| `UNION ALL` | Combine queries |
        """)

    st.divider()
    st.subheader("Graph Data Model")
    st.markdown("""
    ```
    ┌──────────┐    WORKS_ON     ┌──────────┐
    │  Person  │────────────────▶│ Project  │
    └──────────┘                 └──────────┘
         │  │                         │
         │  │ HAS_SKILL               │ DEPENDS_ON
         │  ▼                         ▼
         │ ┌──────────┐         ┌──────────┐
         │ │  Skill   │         │ Project  │
         │ └──────────┘         └──────────┘
         │
         │ BELONGS_TO
         ▼
    ┌──────────┐
    │   Team   │
    └──────────┘

    Person ──MANAGES──▶ Person
    Person ──MENTORS──▶ Person
    ```
    """)

    st.subheader("Node Counts")
    node_data = {
        "Label": ["Person", "Project", "Skill", "Team"],
        "Count": [15, 8, 15, 5],
        "Key Properties": [
            "name, title, department, location",
            "name, status, technology, budget",
            "name, category",
            "name, focus_area",
        ]
    }
    st.table(pd.DataFrame(node_data))
