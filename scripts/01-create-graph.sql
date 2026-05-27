-- ============================================================
-- Script: 01-create-graph.sql
-- Purpose: Create the AGE graph and set up the environment
-- Prerequisites: AGE extension must be enabled
-- ============================================================

-- Session setup (AGE should be preconfigured by admin)

-- Set the search path to include ag_catalog
SET search_path = ag_catalog, "$user", public;

-- Create the graph
SELECT create_graph('techcorp');

-- Verify the graph was created
SELECT * FROM ag_catalog.ag_graph;
