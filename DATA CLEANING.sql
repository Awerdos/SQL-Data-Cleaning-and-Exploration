-- DATA CLEANING PROJECT

-- Initial inspection of the raw data
SELECT *
FROM layoffs
ORDER BY company;

-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Handle NULL and blank values
-- 4. Remove unnecessary columns or rows

-- 1. Remove Duplicates --

-- Create a staging table with the same structure as the raw data
CREATE TABLE staging_layoffs LIKE layoffs;

-- Insert data into the staging table
INSERT INTO staging_layoffs
SELECT *
FROM layoffs;

SELECT * FROM staging_layoffs;

-- Identify duplicates
WITH duplicate_CTE AS 
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM staging_layoffs
)
SELECT *
FROM duplicate_CTE
WHERE row_num > 1;

-- Manual check company with duplicates
SELECT *
FROM staging_layoffs
WHERE company = 'Hibob';

-- Create a second staging table that includes the row_num column
DROP TABLE IF EXISTS staging_layoffs2;
CREATE TABLE staging_layoffs2 AS
WITH duplicate_CTE AS 
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM staging_layoffs
)
SELECT *
FROM duplicate_CTE;

SELECT *
FROM staging_layoffs2
WHERE row_num > 1;

-- Remove duplicate records from the table
DELETE
FROM staging_layoffs2
WHERE row_num > 1;


-- 2. Standardize the Data --

SELECT DISTINCT company
FROM staging_layoffs2
ORDER BY 1;

-- Standardize company names by removing whitespace
UPDATE staging_layoffs2
SET company = TRIM(company);

-- Standardize the Industry column 
SELECT DISTINCT industry
FROM staging_layoffs2
ORDER BY 1;

-- Convert empty strings to NULL
UPDATE staging_layoffs2
SET industry = NULL
WHERE industry = '';

-- Unify various labels for the crypto industry into a single category
SELECT *
FROM staging_layoffs2
WHERE industry LIKE 'Crypto%';

UPDATE staging_layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize Location names
SELECT DISTINCT location, country
FROM staging_layoffs2
ORDER BY 1;

-- Fix spelling
UPDATE staging_layoffs2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

-- Standardize Country names
SELECT DISTINCT country
FROM staging_layoffs2
ORDER BY 1;

-- Fix country name
UPDATE staging_layoffs2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Standardize the Date column
SELECT `date`, STR_TO_Date(`date`, '%m/%d/%Y')
FROM staging_layoffs2;

UPDATE staging_layoffs2
SET `date` = STR_TO_Date(`date`, '%m/%d/%Y');

-- Change the data type of the column to DATE
ALTER TABLE staging_layoffs2
MODIFY COLUMN `date` DATE;


-- 3. Handle NULL and Blank Values --

-- Identify rows where the industry value is missing
SELECT *
FROM staging_layoffs2
WHERE industry IS NULL;

SELECT *
FROM staging_layoffs2 t1
JOIN staging_layoffs2 t2
	ON t1.company = t2.company
    WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;

-- Populate missing industry values using the matched records
UPDATE staging_layoffs2 t1
JOIN staging_layoffs2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM staging_layoffs2
WHERE company = "Bally's Interactive";

SELECT *
FROM staging_layoffs2
WHERE company = "AirBnB";

-- Verify that every record has a valid company name
SELECT company
FROM staging_layoffs2
WHERE company IS NULL;


-- 4. Remove Unnecessary Columns or Rows --

-- Remove records with no useful information
DELETE
FROM staging_layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the helper column
ALTER TABLE staging_layoffs2
DROP COLUMN row_num;

SELECT *
FROM staging_layoffs2;