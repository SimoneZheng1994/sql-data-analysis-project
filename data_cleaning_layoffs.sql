/*
Data Analysis Project - Part 1 - Data Cleaning
Created a new schema via MySQL Workbench and imported raw data using the Table Data Import Wizard.
Raw data originally contained 3,804 records.

In this phase, we will clean the data to prepare it for the next stage: Exploratory Data Analysis (EDA).

The steps we will follow are:
	1. Remove duplicates
	2. Standardize the data
	3. Handle NULL or blank values
	4. Remove any useless columns or rows
*/

-- First, create a staging table to preserve the raw data in case we make mistakes during cleaning.
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Copy all data from the raw table into the staging table.
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Verify the data has been copied correctly.
SELECT *
FROM layoffs_staging;

-- Identify duplicates using ROW_NUMBER() and PARTITION BY.
-- We partition by all columns except date_added to find exact duplicates.
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

-- Three duplicates were found. Let's manually verify one of them to confirm.
SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

-- In MySQL, we cannot delete rows directly from a CTE.
-- Therefore, we create a second staging table that includes the row_num column,
-- then delete duplicates from that table.
CREATE TABLE layoffs_staging2
LIKE layoffs;

ALTER TABLE layoffs_staging2
ADD row_num INT;

-- Insert all data along with row numbers based on the same partition criteria.
INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) AS row_num
FROM layoffs_staging;

-- Delete the three duplicate records (row_num > 1). 3,801 records remain.
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Confirm no duplicates are left.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- ------------------------------------------------------------------------------
-- Standardizing Data
-- ------------------------------------------------------------------------------

-- Check each column for extra spaces or inconsistencies.
-- Trim leading/trailing spaces from the company column.
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check for inconsistencies in the industry column (e.g., blank values, variations).
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Identify rows missing industry information.
SELECT *
FROM layoffs_staging2
WHERE industry = '' OR industry IS NULL;

-- Only one row (company = 'Appsmith') has a blank industry.
-- See if there are other records for the same company that might have a filled industry.
SELECT *
FROM layoffs_staging2
WHERE company = 'Appsmith';

-- No other records exist for Appsmith, so we set its industry to 'Other'.
UPDATE layoffs_staging2
SET industry = 'Other'
WHERE industry = '';

-- Check the country column for inconsistencies.
-- Found one blank (Ludia) and both 'UAE' and 'United Arab Emirates' present.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Standardize 'UAE' to 'United Arab Emirates'.
UPDATE layoffs_staging2
SET country = 'United Arab Emirates'
WHERE country = 'UAE';

-- Review rows with empty country.
SELECT *
FROM layoffs_staging2
WHERE country = '';

-- The blank belongs to Ludia; we know it is based in Canada.
UPDATE layoffs_staging2
SET country = 'Canada'
WHERE company = 'Ludia';

- The `date` column is stored as text; convert it to a proper DATE format.
-- First, preview the conversion.
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Update the column to the standardized date string.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Verify the update.
SELECT `date`
FROM layoffs_staging2;

-- Change the column data type to DATE.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Similarly, the date_added column is text; convert to DATE.
SELECT date_added,
STR_TO_DATE(date_added, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date_added DATE;

-- ------------------------------------------------------------------------------
-- Handling NULL or Blank Values
-- ------------------------------------------------------------------------------

-- Check the stage column for blanks and convert them to NULL.
SELECT *
FROM layoffs_staging2
WHERE stage = '';

UPDATE layoffs_staging2
SET stage = NULL
WHERE stage = '';

-- Other columns appear consistent after previous steps.

-- Identify rows where both total_laid_off and percentage_laid_off are blank/empty.
-- These rows lack the core information we need for analysis.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = '' AND percentage_laid_off = '';

- Convert empty strings in numeric columns to NULL for proper handling.
UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

-- Now, rows with NULLs in both critical columns are useless for our analysis.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Delete those rows.
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Initial raw count: 3,804 rows.
-- After removing duplicates and rows without layoff data: 3,198 rows remain.
-- We removed 606 rows that were irrelevant to our analysis.
SELECT COUNT(*) AS total_rows FROM cleaned_data;

-- Drop the temporary row_num column as it is no longer needed.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- View the final cleaned staging table.
SELECT *
FROM layoffs_staging2;

-- Add a primary key column to facilitate future joins and update operations.
ALTER TABLE layoffs_staging2 ADD COLUMN id INT PRIMARY KEY AUTO_INCREMENT FIRST;

-- Finally, save the cleaned data into a separate table for future queries.
CREATE TABLE cleaned_data
LIKE layoffs_staging2;

INSERT cleaned_data
SELECT *
FROM layoffs_staging2;

-- Verify the cleaned data.
SELECT *
FROM cleaned_data;