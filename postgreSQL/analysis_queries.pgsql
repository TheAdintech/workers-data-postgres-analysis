

---------------------------------- ANALYTICAL QUERIES-------------------------------------

-- Descriptive
--------------

-- 1. What is the overall average age, average hours-per-week, and percentage of workers earning >50K across the whole dataset?
SELECT 
ROUND(AVG(age),1 ) Average_age,
ROUND(AVG("hours-per-week"), 1) Average_hours,
ROUND((100.0 * SUM("income_>50k") / COUNT(*)), 2) overall_pct_above_50k
FROM 
Workers_data;

-- 2. What is the distribution of workers across each workclass category?
SELECT
workclass,
COUNT(*) Number_of_workers
FROM 
Workers_data
GROUP BY workclass
ORDER BY workclass ASC;


-- Comparative
--------------

-- 3. How does the >50K income rate differ by gender?
SELECT 
gender,
ROUND((100.0 * SUM("income_>50k") / COUNT(*)), 2) income_rate
FROM 
Workers_data
GROUP BY gender
ORDER BY gender DESC;

-- 4. How does the >50K income rate differ by marital status?
SELECT 
"marital-status",
ROUND((100.0 * SUM("income_>50k") / COUNT(*)), 2) income_rate
FROM
Workers_data
GROUP BY "marital-status"
ORDER BY income_rate;

-- 5. Which occupations have the highest >50K income rate (with a reasonable minimum sample size)?
SELECT 
occupation,
ROUND((100.0 * SUM("income_>50k") / COUNT(*)) , 2) income_rate
FROM 
Workers_data
GROUP BY occupation
ORDER BY income_rate DESC
LIMIT 10;


-- Relational
-------------

-- 6. Is there a correlation between age and hours-per-week?
SELECT
ROUND(CORR(age, "hours-per-week") :: numeric, 2)  age_vs_work_hours
FROM 
Workers_data;

-- 7. Is there a correlation between education level and hours-per-week?
SELECT
ROUND(CORR(educational_num,"hours-per-week") ::numeric, 3) as education_vs_work_hours
FROM
Workers_data;

-- 8. Is there a correlation between age and capital-gain?
SELECT 
ROUND(CORR(age, "capital-gain"):: numeric, 3) as age_vs_capital_gain
FROM
Workers_data;

-- 9. Is there a correlation between education level and capital-gain?
SELECT 
ROUND(CORR(educational_num, "capital-gain") :: numeric, 3) as education_vs_capital_gain
FROM
Workers_data;


-- Anomaly / Outlier
--------------------

-- 10. Who works the most hours per week, and what does their profile look like?
SELECT 
*
FROM
Workers_data
WHERE "hours-per-week" = (SELECT MAX("hours-per-week") FROM Workers_data);

-- 11. Are there any workers with low education levels who still earn >50K — what do they have in common?
SELECT 
* 
FROM 
Workers_data
WHERE educational_num < 10 AND "income_>50k" = 1;

-- 12. Is there a pattern among workers who have capital-loss but no capital-gain?
SELECT
occupation, education,
COUNT(*) AS Number_of_Workers, 
ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS ROW_NUMBER,
RANK() OVER(ORDER BY COUNT(*) DESC) AS RANK,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS DENSE_RANK
FROM 
Workers_data
WHERE "capital-loss" > 0 AND "capital-gain" = 0
GROUP BY  occupation, education
LIMIT 10;


-- Window Functions
-------------------

-- 13. How do occupations rank against each other by their >50K income rate?
SELECT 
occupation,
ROUND((100.0 * SUM("income_>50k") / COUNT(*)), 2) Pct_Above_50K,
RANK() OVER(ORDER BY ROUND((100.0 * SUM("income_>50k") / COUNT(*)), 2) DESC)  Rank
FROM
Workers_data
WHERE Occupation != '?'
GROUP BY Occupation;

-- 14. For each worker, how do their hours-per-week compare to their occupation's average?
SELECT 
occupation, age,
"hours-per-week",
ROUND(AVG("hours-per-week") OVER(PARTITION BY occupation), 2)  Occupation_Avg_Hours,
ROUND("hours-per-week" - AVG("hours-per-week") OVER(PARTITION BY occupation), 2)
difference_from_occupation_Avg
FROM
Workers_data
ORDER BY occupation, age
LIMIT 20;

-- 15. What does the cumulative (running total) count of workers look like as age increases?
SELECT age, COUNT(*) AS Number_of_workers,
    SUM(COUNT(*)) OVER (ORDER BY age) AS running_total
FROM workers_data
GROUP BY age;

-- Show the number of workers in each age group (e.g., young, middle-aged, older) and the corresponding age ranges.
SELECT 
count(*) Number_of_workers, age,
CASE 
WHEN age < 30 THEN 'Young'
WHEN age BETWEEN 30 AND 50 THEN 'Middle-Aged'
WHEN age > 50 THEN 'Older'
END AS age_group
FROM
Workers_data 
Group by Age;