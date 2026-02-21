# Layoffs Data Analysis (2020–2026)

This project cleans and explores a dataset of company layoffs from 2020 to 2026. The goal is to demonstrate data cleaning skills and extract meaningful insights using SQL.

## Files
- `layoffs.csv` – raw dataset (3,804 records)
- `data_cleaning_layoffs.sql` – cleaning script (duplicates, standardization, null handling)
- `exploratory_data_analysis_layoffs.sql` – exploratory queries

## Process
### 1. Data Cleaning
- Created staging tables to preserve raw data.
- Removed duplicate records using `ROW_NUMBER()` and `PARTITION BY`.
- Standardized values (trimmed spaces, fixed industry/country inconsistencies, converted date strings to `DATE`).
- Handled blanks by converting empty strings to `NULL`.
- Deleted 606 rows missing both `total_laid_off` and `percentage_laid_off`.
- Final clean dataset: **3,198 records**.

### 2. Exploratory Analysis
- Aggregated layoffs by company, industry, country, year, and company stage.
- Calculated monthly rolling totals and month-over-month percentage changes.
- Ranked top 5 companies per year with `DENSE_RANK()`.
- Analyzed distribution of `percentage_laid_off` and funds raised buckets.
- Examined reporting sources and delay between layoff date and entry date.

## Key Findings
- **Industries hit hardest**: Consumer, Retail, Transportation, and Finance.
- **Countries with most layoffs**: United States, India, United Kingdom.
- **Peak years**: 2023–2024 saw the highest totals.
- **Top companies**: Amazon, Google-parent Alphabet, Microsoft, Meta, and Salesforce repeatedly top the annual rankings.
- **Percentage laid off**: More than half of events involved less than 30% of the workforce; extreme cases (>50%) are rare.
- **Funding correlation**: Companies with >$1B raised account for the largest layoff events, but smaller startups also appear frequently.

## Technologies
- **MySQL** – all cleaning and analysis.
- **SQL techniques**: CTEs, window functions, data type conversion, conditional updates, rolling aggregates.
