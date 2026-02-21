-- Exploratory Data Analysis

SELECT *
FROM cleaned_data;

-- Troviamo l'intervallo temporale preso in esame, risultato (2020-03-11, 2026-02-11)
SELECT MIN(`date`) AS start_date, MAX(`date`) AS end_date
FROM cleaned_data;

-- Nell'intervallo preso in esame, troviamo le compagnie che hanno licenziato più persone
SELECT company, SUM(total_laid_off) AS laid_off
FROM cleaned_data
GROUP BY company
ORDER BY laid_off DESC;

-- In maniera simile, troviamo i settori industriali che hanno licenziato più persone
SELECT industry, SUM(total_laid_off) AS laid_off
FROM cleaned_data
GROUP BY industry
ORDER BY laid_off DESC;

-- Stessa cosa per i paesi
SELECT country, SUM(total_laid_off) AS laid_off
FROM cleaned_data
GROUP BY country
ORDER BY laid_off DESC;

-- Per gli anni
SELECT YEAR(`date`), SUM(total_laid_off) AS laid_off
FROM cleaned_data
GROUP BY YEAR(`date`)
ORDER BY laid_off DESC;

-- E per la maturità dell'azienda
SELECT stage, SUM(total_laid_off) AS laid_off
FROM cleaned_data
GROUP BY stage
ORDER BY laid_off DESC;

-- rolling total: mostra come col progradire dei mesi il totale dei licenziati aumenti

WITH rolling_total_cte AS
(
-- determina il totale dei licenziati per mese
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_monthly_laid_off
FROM cleaned_data
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month` ASC
)
SELECT `month`, total_monthly_laid_off, SUM(total_monthly_laid_off) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total_cte;

WITH company_year (company, `year`, total_laid_off)AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM cleaned_data
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
FROM company_year
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;