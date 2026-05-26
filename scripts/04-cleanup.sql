-- ============================================================
-- Script: 04-cleanup.sql
-- Purpose: Drop the graph and clean up (for resetting the workshop)
-- ============================================================

-- Load the AGE extension and set search path
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Drop the graph (cascade drops all vertices and edges)
SELECT drop_graph('techcorp', true);

-- Verify the graph was dropped
SELECT * FROM ag_catalog.ag_graph;
