-- .read Lesson\1.21\1.20_DDL_&_DML_Pt_1.sql

CREATE DATABASE jobs_mart;

SHOW DATABASES;

CREATE DATABASE IF NOT EXISTS jobs_mart;

-- DROP DATABASE jobs_mart;

-- DROP DATABASE IF EXISTS jobs_mart;

SELECT * 
FROM information_schema.schemata;

USE jobs_mart;

CREATE SCHEMA IF NOT EXISTS staging;

-- DROP SCHEMA staging;

-- Creating a new table under the staging schema
CREATE TABLE IF NOT EXISTS staging.preferred_roles (
        role_id INTEGER PRIMARY KEY, 
        role_name VARCHAR
);

SELECT * 
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';


-- Inserting data into the table columns created
INSERT INTO staging.preferred_roles (role_id,role_name)
VALUES 
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');

SELECT *
FROM staging.preferred_roles;

-- Creating a new column to the table
ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

/* inserting into the new column added using UPDATE instead of
instead of using INSERT INTO */
UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE role_id = 1 OR role_id = 2;

UPDATE staging.priority_roles
SET priority_lvl = FALSE
WHERE role_id = 3;

-- Renaming the table 'preferred_roles' to 'priority_roles' 
ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

-- Renaming the column 'preferred_roles' to 'priority_lvl'
ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

-- Chaning the column 'priority_lvl' data type
ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl
    TYPE INTEGER;

UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

SELECT *
FROM staging.priority_roles;