-- UNION
SELECT UNNEST([1,1,1,2])
UNION 
SELECT UNNEST ([1,1,3]);

-- UNION ALL
SELECT UNNEST([1,1,1,2])
UNION ALL
SELECT UNNEST ([1,1,3]);

--INTERSECT
SELECT UNNEST([1,1,1,2])
INTERSECT
SELECT UNNEST ([1,1,3]);

-- INTERSECT ALL
SELECT UNNEST([1,1,1,2])
INTERSECT ALL
SELECT UNNEST ([1,1,3]);

-- EXCEPT
SELECT UNNEST([1,1,1,2])
EXCEPT
SELECT UNNEST ([1,1,3]);

-- EXCEPT ALL
SELECT UNNEST([1,1,1,2])
EXCEPT ALL
SELECT UNNEST ([1,1,3]);

-- FINAL EXAMPLE
-- 1) Which unique job postings appeared in either 2023 or 2024?
-- 2) Which job postings appeared across both years, counting duplicates?
-- 3) Which job postings appeared in both 2023 and 2024?
-- 4) Which job postings appeared in both years, preserving duplicate counts?
-- 5) Which job postings appeared in 2023 but not in 2024?
-- 6) Which job postings appeared more times in 2023 than 2024, one-for-one?

-- TABLE A
CREATE TEMP TABLE job_2023 AS
SELECT * EXCLUDE (job_id,job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

-- TABLE B
CREATE TEMP TABLE job_2024 AS
SELECT * EXCLUDE (job_id,job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;

-- 1) Which unique job postings appeared in either 2023 or 2024?

SELECT *
FROM job_2023
UNION
SELECT *
FROM job_2024;


-- 2) Which job postings appeared across both years, counting duplicates?

SELECT *
FROM job_2023
UNION ALL
SELECT *
FROM job_2024;


-- 3) Which job postings appeared in 2023 but not in 2024?
SELECT *
FROM job_2023
EXCEPT
SELECT *
FROM job_2024;

-- 4) Which job postings from 2023 remain after subtracting matching 2024 postings, one-for-one?

SELECT *
FROM job_2023
EXCEPT ALL
SELECT *
FROM job_2024;

-- 5) Which job postings appeared in both 2023 and 2024?

SELECT *
FROM job_2023
INTERSECT
SELECT *
FROM job_2024;

-- 6) Which job postings appeared in both years, preserving duplicate counts?

SELECT *
FROM job_2023
INTERSECT ALL
SELECT *
FROM job_2024;