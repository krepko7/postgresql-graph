# Step 7: Create a GitHub Repository

## Prerequisites

- [Git](https://git-scm.com/downloads) installed
- [GitHub CLI](https://cli.github.com/) installed (recommended) or a GitHub account

## Option A: Using GitHub CLI (Recommended)

### 1. Authenticate with GitHub

```bash
gh auth login
```

Follow the prompts to authenticate via browser or token.

### 2. Initialize the Local Repository

```bash
cd C:\copilot\graph

git init
git add .
git commit -m "Initial commit: PostgreSQL Graph Workshop with Apache AGE"
```

### 3. Create the GitHub Repository

```bash
gh repo create postgresql-age-graph-workshop \
    --public \
    --description "Workshop: Graph database capabilities in Azure PostgreSQL using Apache AGE" \
    --source . \
    --push
```

This creates the repo and pushes in one command.

---

## Option B: Manual GitHub Setup

### 1. Create Repository on GitHub

1. Go to [github.com/new](https://github.com/new)
2. Fill in:
   - **Repository name:** `postgresql-age-graph-workshop`
   - **Description:** Workshop: Graph database capabilities in Azure PostgreSQL using Apache AGE
   - **Visibility:** Public (or Private)
   - **Do NOT** initialize with README (we already have one)
3. Click **Create repository**

### 2. Initialize and Push

```bash
cd C:\copilot\graph

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: PostgreSQL Graph Workshop with Apache AGE"

# Set the main branch
git branch -M main

# Add the remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/postgresql-age-graph-workshop.git

# Push to GitHub
git push -u origin main
```

---

## Add a .gitignore

Create a `.gitignore` to exclude unnecessary files:

```bash
# Already included in the repo - see .gitignore file
```

---

## Repository Topics (Optional)

Add topics to make the repo discoverable:

```bash
gh repo edit --add-topic postgresql,graph-database,apache-age,cypher,workshop,azure
```

---

## Verify

After pushing, verify your repository at:

```
https://github.com/YOUR_USERNAME/postgresql-age-graph-workshop
```

You should see the README rendered with the workshop overview, directory structure, and graph data model diagram.

---

## Sharing with Workshop Participants

Share the clone URL:

```bash
git clone https://github.com/YOUR_USERNAME/postgresql-age-graph-workshop.git
cd postgresql-age-graph-workshop
```

Participants can then follow the docs in order:
1. [Azure Setup](01-azure-setup.md)
2. [Enable AGE](02-enable-age.md)
3. [VS Code Setup](03-vscode-setup.md)
4. [Load Data](04-load-data.md)
5. [Cypher Queries](05-graph-queries.md)
6. [Hybrid Queries](06-hybrid-queries.md)
