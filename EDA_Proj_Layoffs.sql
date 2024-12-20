-- EXPLORATORY DATA ANALYSIS PROJECT
-- USING THE SAME CLEANED DATA OF LAYOFFS

SELECT * FROM layoffs2;

SELECT MAX(total_laid_off), max(percentage_laid_off) FROM layoffs2;

SELECT * FROM layoffs2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * FROM layoffs2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(Total_laid_off) FROM layoffs2
group by company
ORDER BY 2 desc;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs2;

SELECT industry, SUM(Total_laid_off) FROM layoffs2
group by industry
ORDER BY 2 desc;


SELECT country, SUM(Total_laid_off) FROM layoffs2
group by country
ORDER BY 2 desc;

SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) FROM layoffs2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL -- THATSY HERE ALIAS IS NOT USED
GROUP BY `MONTH`
HAVING `MONTH`
ORDER BY 1 ASC;

-- LOGICAL QUERY EXECUTION ORDER
/* 
FROM
WHERE
GROUP BY
HAVING
SELECT
ORDER BY
LIMIT */

-- In logical execution order group by and having comes before select. then how im able to use alias name in having and group by?
/*Logical Execution Order:

Conceptually, GROUP BY and HAVING happen before SELECT because they operate on the dataset created in earlier steps (e.g., after WHERE).
In this logical flow, GROUP BY organizes rows into groups, and HAVING filters those groups.
SQL Engine Optimization:

In reality, SQL engines often process queries in a way that allows optimizations and shortcuts.
While GROUP BY and HAVING logically precede SELECT, the engine is aware of the aliases defined in SELECT because it parses the entire query before execution begins 

Example:

sql
Copy code
SELECT SUBSTRING(date, 1, 7) AS MONTH
FROM layoffs2
GROUP BY MONTH;

The engine translates this to:
sql
Copy code
SELECT SUBSTRING(date, 1, 7) AS MONTH
FROM layoffs2
GROUP BY SUBSTRING(date, 1, 7); 

The WHERE clause operates on raw data, which is processed before the SELECT clause is executed.

Aliases are not yet available at the WHERE stage because they are created in the SELECT clause. */

-- QUERY WRITING ORDER
/*
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT */

-- A rolling total (also known as a running total or cumulative sum) is a calculation that continuously sums up values over a specified sequence
/* LIKE THIS 
MONTH   TOTAL_OFF rolling_total
'2020-03', '9628', '9628'
'2020-04', '26710', '36338'
'2020-05', '25804', '62142' */


WITH Rolling_Total as(
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) AS Total_off FROM layoffs2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL -- THATSY HERE ALIAS IS NOT USED
GROUP BY `MONTH`
HAVING `MONTH`
ORDER BY 1 ASC)
SELECT `MONTH`, Total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;

WITH Rolling_Total as(
SELECT SUBSTRING(`date`,1,7) AS `MONTH` , SUM(total_laid_off) AS Total_off FROM layoffs2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL -- THATSY HERE ALIAS IS NOT USED
GROUP BY `MONTH`
HAVING `MONTH`
ORDER BY 1 ASC)
SELECT SUM(Total_off)
FROM Rolling_Total;

-- TO SEE WHICH COMPANY LAID OFF MORE AND ON WHICH YEAR
SELECT company, YEAR(`date`), SUM(Total_laid_off) FROM layoffs2
group by company, YEAR(`date`)
ORDER BY 3 desc;

WITH Company_year as(
SELECT company, YEAR(`date`) AS YEARS, SUM(Total_laid_off) AS Total_laid_off FROM layoffs2
group by company, YEAR(`date`)
ORDER BY 3 desc
), Company_year_rank AS(
SELECT *,
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
FROM Company_year
where years is not null
)
SELECT *
FROM Company_year_rank
where Ranking <=5;


