-- Step 4: Mart - Create skills demand mart

-- Drop existing mart schema if it exists (for idempotency)
DROP SCHEMA IF EXISTS skills_mart CASCADE;
DROP TABLE IF EXISTS skills_mart.dim_skills;
DROP TABLE IF EXISTS  skills_mart.dim_date_month;
DROP TABLE IF EXISTS skills_mart.fact_skill_demand_monthly;

-- Step 1: Create the mart schema
CREATE SCHEMA skills_mart;

-- 1. Skills dimension
CREATE TABLE skills_mart.dim_skills (
    skill_id    INTEGER PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);

SELECT '== Loading skills for skill mart ==' AS info;
INSERT INTO skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;
 
-- 2. Month-level date dimension (enhanced with quarter and other attributes)
CREATE TABLE skills_mart.dim_date_month (
    month_start_date        DATE    PRIMARY KEY,
    year                    INTEGER,
    month                   INTEGER,
    quarter                 INTEGER,
    quarter_name            VARCHAR,
    year_quarter            VARCHAR
);

SELECT '== Loading date month for skills mart ==' AS info;
INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date):: VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' ||  
    EXTRACT(QUARTER FROM job_posted_date) AS year_quarter
FROM job_postings_fact
ORDER BY month_start_date;

-- Step 3: Create fact table - fact_skill_demand_monthly
-- Grain: skill_id + month_start_date + job_title_short
-- All measures are additive (counts and sums) - safe to re-aggregate
CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id                            INTEGER,
    month_start_date                    DATE,
    job_title_short                     VARCHAR,
    postings_count                      VARCHAR,
    remote_postings_count               VARCHAR,
    health_insurance_postings_count     VARCHAR,
    no_degree_mentioned_postings_count  VARCHAR,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

SELECT '== Loading Skill fact for skills mart ==' AS info;
INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mentioned_postings_count
)
WITH job_postings_prep AS (
SELECT 
    sjd.skill_id,
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    jpf.job_title_short,
    -- convert boolean flags (1 or 0)
    CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
    CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned
FROM 
    job_postings_fact AS jpf
INNER JOIN
    skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
)
SELECT 
    skill_id,
    month_start_date,
    job_title_short,
     -- Additive counts
    COUNT(*) AS postings_count,
    -- Remote / benefits / degree flags (additive counts)
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mentioned) AS no_degree_mentioned_postings_count
FROM 
    job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date, job_title_short;


-- Data Validation
-- Verify mart was created
SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Month Dimension', COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skilled Deman Fact', COUNT(*) FROM skills_mart.fact_skill_demand_monthly;

SELECT '== Skill Dimension Sample ==';
SELECT * FROM skills_mart.dim_skills LIMIT 5;

SELECT '== Date Month Dimension Sample ==';
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '== Skill Demand Fact Sample ==';
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;