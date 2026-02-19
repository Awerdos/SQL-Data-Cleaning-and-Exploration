-- DATA EXPLORATION

-- General overview
SELECT *
FROM staging_layoffs2;

-- Checking the maximum and minimum values for all numerical columns to understand the data range
SELECT MAX(total_laid_off), MIN(total_laid_off),
MAX(percentage_laid_off), MIN(percentage_laid_off),
MAX(`date`), MIN(`date`),
MAX(funds_raised_millions), MIN(funds_raised_millions)
FROM staging_layoffs2;

-- Observing records where the percentage of layoffs is listed as 0.
-- Investigation shows that some of these companies actually laid off employees 52 people,
-- which suggests that '0' represents a tiny fraction rather than an actual zero value.
SELECT *
FROM staging_layoffs2
WHERE percentage_laid_off = 0;

-- Analyzing the frequency and timing of layoff waves for companies.
-- This helps identify how often companies returned to job cuts.
WITH company_analysis AS
(
SELECT *,
COUNT(*) OVER(PARTITION BY company) AS comp_count,
ROW_NUMBER() OVER(PARTITION BY company ORDER BY `date`),
DENSE_RANK() OVER(PARTITION BY company ORDER BY `date`) AS laidoff_wave,
LAG(`date`) OVER(PARTITION BY company ORDER BY `date`) AS previous_laidoff
FROM staging_layoffs2
)
SELECT company, `date`, DATEDIFF(`date`, previous_laidoff) as days_between_layoffs, total_laid_off, laidoff_wave
FROM company_analysis
WHERE comp_count >= 2;

-- Identifying which countries recorded the highest number of total layoffs
SELECT country, SUM(total_laid_off) AS total_laid_off_country
FROM staging_layoffs2
GROUP BY country
ORDER BY total_laid_off_country DESC;

-- Identifying which industries were most affected by layoffs
SELECT industry, SUM(total_laid_off) AS total_laid_off_industry
FROM staging_layoffs2
GROUP BY industry
ORDER BY total_laid_off_industry DESC;

-- Aggregating total layoffs per month to observe time-based trends
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS sum_per_month
FROM staging_layoffs2
GROUP BY `MONTH`
HAVING `MONTH` IS NOT NULL
ORDER BY `MONTH`;

-- Calculating the cumulative sum of layoffs month-over-month
WITH rolling_sum AS(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS sum_per_month
FROM staging_layoffs2
GROUP BY `MONTH`
HAVING `MONTH` IS NOT NULL
ORDER BY `MONTH`
)
SELECT *, SUM(sum_per_month) OVER(ORDER BY `MONTH`) AS monthly_cumulative_total
FROM rolling_sum;

-- Summarizing total layoffs per company, broken down by year
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) as total_sum
FROM staging_layoffs2
GROUP BY company, YEAR(`date`)
HAVING total_sum IS NOT NULL AND `year` IS NOT NULL
ORDER BY 3 DESC;

-- Ranking the top 5 companies with the highest number of layoffs for each specific year
WITH Company_year AS(
SELECT company, YEAR(`date`) AS `year`, SUM(total_laid_off) as total_sum
FROM staging_layoffs2
GROUP BY company, YEAR(`date`)
HAVING total_sum IS NOT NULL AND `year` IS NOT NULL
), Company_year_rank AS(
SELECT *,
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_sum DESC) AS ranking
FROM Company_year
ORDER BY ranking
)
SELECT *
FROM Company_year_rank
WHERE ranking <= 5;

-- Calculating the total funds raised by companies in each country
SELECT country, SUM(funds_raised_millions) AS total_funds_raised
FROM staging_layoffs2
GROUP BY country
ORDER BY 2 DESC;

-- Comparing the total funds raised against the total number of layoffs per company
SELECT company, SUM(funds_raised_millions) AS total_funds, SUM(total_laid_off) AS total_layoffs
FROM staging_layoffs2
GROUP BY company
ORDER BY 2 DESC;



