SELECT CHAR_LENGTH('SQL');

SELECT LOWER('SQL');

SELECT UPPER('Sql');

SELECT LEFT('SQL',2);

SELECT RIGHT('SQL',2);

SELECT SUBSTRING('SQL',2,2)

SELECT CONCAT('SQL'|| '-'|| 'Functions');

SELECT TRIM(' SQL ');

SELECT REPLACE ('SQL', 'Q', '-');

SELECT REGEX_REPLACE('data.nerd@gmail.com', '^.*(g)', '\1');

-- FINAL EXAMPLE
WITH title_lower AS (
    SELECT
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)

SELECT 
    job_title,
    CASE
        WHEN job_title_clean LIKE '%data%'
        AND job_title_clean LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%aata%'
        AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE '%data%'
        AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;



SELECT
    salary_year_avg,
    salary_hour_avg
FROM 
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
ORDER BY salary_year_avg
LIMIT 10;


SELECT COALESCE(NULL,NULL,2);

SELECT
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg *2080)
FROM 
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

--Final Example
WITH salaries AS(
    SELECT
        job_title_short,
        salary_year_avg,
        salary_hour_avg
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
            ELSE NULL
            END AS standardised_salary
        FROM job_postings_fact
)
SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    standardised_salary
    CASE 
        WHEN standardised_salary IS NOT NULL THEN 'Missing'
        WHEN standardised_salary < 75000 THEN 'Low'
        WHEN standardised_salary > 150000 THEN 'High'
        ELSE 'High'
    END AS salary_bucket
FROM salaries
ORDER BY standardised_salary DESC
LIMIT 20;




SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg *2080),
    CASE 
        WHEN COALESCE(salary_year_avg, salary_hour_avg *2080) IS NOT NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_hour_avg *2080) < 75000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_hour_avg *2080) > 150000 THEN 'High'
        ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY COALESCE(salary_year_avg, salary_hour_avg *2080) DESC
LIMIT 20;