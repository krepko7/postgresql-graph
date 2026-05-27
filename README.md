# PostgreSQL Graph Database Workshop with Apache AGE

This workshop demonstrates how to use graph database capabilities in **Azure PostgreSQL Flexible Server** using the **Apache AGE (A Graph Extension)** extension. You'll learn to model, load, and query graph data using Cypher and hybrid SQL/Cypher queries.

## Workshop Scenario

We'll model a **technology company's organizational and project graph** including:
- **People** (employees) with roles and departments
- **Projects** with technologies and timelines
- **Skills** that people possess
- **Teams** that people belong to
- Relationships: WORKS_ON, HAS_SKILL, MANAGES, MENTORS, DEPENDS_ON, BELONGS_TO

## Prerequisites

1. **Azure Subscription** — Free tier or pay-as-you-go
2. **Azure CLI** — [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **VS Code** — [Download VS Code](https://code.visualstudio.com/)
4. **VS Code PostgreSQL Extension** — Install from the VS Code Marketplace
5. **psql client** (optional) — For command-line access

## Quick Start

1. [Set up Azure PostgreSQL Flexible Server](docs/01-azure-setup.md)
2. [Enable Apache AGE Extension](docs/02-enable-age.md)
3. [Configure VS Code PostgreSQL Extension](docs/03-vscode-setup.md)
4. [Load Sample Data](docs/04-load-data.md)
5. [Run Graph Queries](docs/05-graph-queries.md)
6. [Advanced Hybrid Queries](docs/06-hybrid-queries.md)

## Repository Structure

```
graph/
├── README.md                  # This file
├── app/
│   ├── README.md              # App setup instructions
│   ├── app.py                 # Streamlit app (main)
│   ├── queries.py             # Pre-built query definitions
│   ├── requirements.txt       # Python dependencies
│   └── .env.example           # Connection config template
├── data/
│   ├── nodes_people.csv       # People node data
│   ├── nodes_projects.csv     # Project node data
│   ├── nodes_skills.csv       # Skill node data
│   ├── nodes_teams.csv        # Team node data
│   ├── edges_works_on.csv     # WORKS_ON relationships
│   ├── edges_has_skill.csv    # HAS_SKILL relationships
│   ├── edges_manages.csv      # MANAGES relationships
│   ├── edges_mentors.csv      # MENTORS relationships
│   ├── edges_depends_on.csv   # DEPENDS_ON relationships
│   └── edges_belongs_to.csv   # BELONGS_TO relationships
├── scripts/
│   ├── 01-create-graph.sql    # Create the graph schema
│   ├── 02-load-nodes.sql      # Load all node data
│   ├── 03-load-edges.sql      # Load all edge data
│   ├── 04-update-graph.sql    # Update graph data examples
│   └── 05-cleanup.sql         # Drop graph (for reset)
├── queries/
│   ├── cypher-queries.sql     # Pure Cypher queries
│   └── hybrid-queries.sql     # Hybrid SQL/Cypher queries
└── docs/
    ├── 01-azure-setup.md      # Azure PostgreSQL setup guide
    ├── 02-enable-age.md       # Enable AGE extension
    ├── 03-vscode-setup.md     # VS Code configuration
    ├── 04-load-data.md        # Data loading instructions
    ├── 05-graph-queries.md    # Cypher query tutorial
    ├── 06-hybrid-queries.md   # Hybrid query tutorial
    └── 07-github-setup.md     # Push to GitHub
```

## Graph Data Model

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

## Streamlit App

A web-based frontend to test and compare queries interactively:

```bash
cd app
pip install -r requirements.txt
streamlit run app.py
```

Features:
- **Compare Queries** — See SQL vs Cypher vs Hybrid side-by-side with execution timing
- **Custom Query Editor** — Write and run your own Cypher/hybrid queries
- **Reference** — Quick syntax guide and data model

See [app/README.md](app/README.md) for full setup instructions.

## Push to GitHub

See [docs/07-github-setup.md](docs/07-github-setup.md) for instructions on creating a GitHub repo and pushing this workshop.

## License

MIT License — Feel free to use this workshop material for learning and teaching.
