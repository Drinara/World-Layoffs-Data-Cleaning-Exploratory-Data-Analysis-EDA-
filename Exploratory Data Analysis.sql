-- Exploratory Data Analysis
#see what companies laid off all of their workers and hor much they raised 
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;
#Companies total layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2;
#Industry total layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;
#Country total layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;
#Year total layoffs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
SELECT DATE_FORMAT(`date`, '%Y-%m') AS `year_month`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY 1 DESC;

#Stage total layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
#Rolling total is like previous + new to see how much uptill that point. No partition accross the years
WITH Rolling_Total AS (
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laid
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_laid,
SUM(total_laid) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
#Rolling total is like previous + new to see how much uptill that point. With partition accross the years
WITH Rolling_Total2 AS (
SELECT YEAR(`date`) AS `Year`, SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laid
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Year`, `MONTH`
ORDER BY 1 ASC
)
SELECT `Year`, `MONTH`, total_laid,
SUM(total_laid) OVER(PARTITION BY `Year` ORDER BY `MONTH`) AS rolling_total2
FROM Rolling_Total2;

SELECT company, SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL AND total_laid_off IS NOT NULL
GROUP BY company, `MONTH`
ORDER BY 1 ASC;

#Rolling Total of the Company based on dates 
WITH Rolling_Total3 AS (
SELECT company, SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laid
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL  AND total_laid_off IS NOT NULL
GROUP BY company, `MONTH`
ORDER BY 1 DESC
)
SELECT company, `MONTH`, total_laid,
SUM(total_laid) OVER(PARTITION BY company ORDER BY `MONTH`) AS rolling_total3
FROM Rolling_Total3;

#Ranking the company with the top layoffs. 
WITH Company_Year (company, years, laid_off_total) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
WHERE `date` IS NOT NULL  AND total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)
), 
Company_Year_Rank AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY laid_off_total DESC) AS ranking
FROM Company_Year
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;

#Ranking the industry with the top layoffs. You can do for stage, country etc
WITH Industry_Year (industry, years, laid_off_total) AS (
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
WHERE `date` IS NOT NULL  AND total_laid_off IS NOT NULL
GROUP BY industry, YEAR(`date`)
), 
Industry_Year_Rank AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY laid_off_total DESC) AS ranking
FROM Industry_Year
)
SELECT *
FROM Industry_Year_Rank
WHERE ranking <= 5;