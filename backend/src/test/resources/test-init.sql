-- Test database initialization script
-- This script sets up the basic schema for integration tests

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone for consistent testing
SET timezone = 'UTC';

-- Create any test-specific functions or triggers here if needed
-- The actual schema will be created by Hibernate during test execution