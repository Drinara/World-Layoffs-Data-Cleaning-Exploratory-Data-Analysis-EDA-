# **World Layoffs Data Cleaning & Exploratory Data Analysis (EDA) with MYSQL**

## **Overview**
This project involves cleaning a large layoffs dataset and performing exploratory data analysis (EDA) to uncover key patterns and trends in global layoffs. The analysis focuses on various factors such as company layoffs, industry trends, country-specific layoffs, and temporal patterns (year, month, etc.). SQL queries are used for both data cleaning and in-depth analysis.

## **Table of Contents**
1. [Data Cleaning](#data-cleaning)
2. [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)
    1. [Identifying Companies with 100% Layoffs](#identifying-companies-with-100-layoffs)
    2. [Maximum Layoffs and Percentage Laid Off](#maximum-layoffs-and-percentage-laid-off)
    3. [Total Layoffs by Company](#total-layoffs-by-company)
    4. [Date Range of Layoffs](#date-range-of-layoffs)
    5. [Total Layoffs by Industry](#total-layoffs-by-industry)
    6. [Total Layoffs by Country](#total-layoffs-by-country)
    7. [Total Layoffs by Year](#total-layoffs-by-year)
    8. [Total Layoffs by Year-Month](#total-layoffs-by-year-month)
    9. [Total Layoffs by Stage](#total-layoffs-by-stage)
    10. [Monthly Layoffs](#monthly-layoffs)
    11. [Rolling Total of Layoffs (Unpartitioned)](#rolling-total-of-layoffs-unpartitioned)
    12. [Rolling Total of Layoffs (Partitioned by Year)](#rolling-total-of-layoffs-partitioned-by-year)
    13. [Company-Level Monthly Layoffs](#company-level-monthly-layoffs)
    14. [Rolling Total of Layoffs by Company](#rolling-total-of-layoffs-by-company)
    15. [Top Companies with the Most Layoffs by Year](#top-companies-with-the-most-layoffs-by-year)
    16. [Top Industries with the Most Layoffs by Year](#top-industries-with-the-most-layoffs-by-year)

## **Data Cleaning**
The following queries handle basic data cleaning tasks, such as checking for missing values, duplicates, and standardizing data.

### 1. **Identifying Missing or Inconsistent Data**
This query identifies any records with missing or inconsistent data.
```sql
SELECT * 
FROM layoffs_staging_2
WHERE total_laid_off IS NULL OR company IS NULL;
```

---

## **Exploratory Data Analysis (EDA)**

### 1. **Identifying Companies with 100% Layoffs**
This query retrieves companies that laid off 100% of their workforce, and sorts them by funds raised.
```sql
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
```

### 2. **Maximum Layoffs and Percentage Laid Off**
This query finds the maximum values of total layoffs and the percentage of employees laid off.
```sql
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;
```

### 3. **Total Layoffs by Company**
This query aggregates the total layoffs per company and sorts them in descending order.
```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;
```

### 4. **Date Range of Layoffs**
This query provides the earliest and latest dates in the layoffs dataset.
```sql
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2;
```

### 5. **Total Layoffs by Industry**
This query aggregates the total layoffs by industry and orders them by total layoffs.
```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;
```

### 6. **Total Layoffs by Country**
This query sums the total layoffs by country and orders them by total layoffs in descending order.
```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;
```

### 7. **Total Layoffs by Year**
This query aggregates layoffs by year, allowing for a year-wise analysis.
```sql
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
```

### 8. **Total Layoffs by Year-Month**
This query aggregates layoffs by year and month.
```sql
SELECT DATE_FORMAT(`date`, '%Y-%m') AS `year_month`, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY 1 DESC;
```

### 9. **Total Layoffs by Stage**
This query sums the layoffs based on the stage of the company (e.g., startup, growth).
```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;
```

### 10. **Monthly Layoffs**
This query aggregates the layoffs by month.
```sql
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
```

### 11. **Rolling Total of Layoffs (Unpartitioned)**
This query calculates the rolling total of layoffs without partitioning across years.
```sql
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
```

### 12. **Rolling Total of Layoffs (Partitioned by Year)**
This query calculates the rolling total of layoffs partitioned by year.
```sql
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
```

### 13. **Company-Level Monthly Layoffs**
This query aggregates layoffs by company and month.
```sql
SELECT company, SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL AND total_laid_off IS NOT NULL
GROUP BY company, `MONTH`
ORDER BY 1 ASC;
```

### 14. **Rolling Total of Layoffs by Company**
This query calculates the rolling total of layoffs for each company.
```sql
WITH Rolling_Total3 AS (
    SELECT company, SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laid
    FROM layoffs_staging_2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL AND total_laid_off IS NOT NULL
    GROUP BY company, `MONTH`
    ORDER BY 1 DESC
)
SELECT company, `MONTH`, total_laid,
SUM(total_laid) OVER(PARTITION BY company ORDER BY `MONTH`) AS rolling_total3
FROM Rolling_Total3;
```

### 15. **Top Companies with the Most Layoffs by Year**
This query ranks the top companies by the total layoffs each year.
```sql
WITH Company_Year (company, years, laid_off_total) AS (
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging_2
    WHERE `date` IS NOT NULL AND total_laid_off IS NOT NULL
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
```

### 16. **Top Industries with the Most Layoffs by Year**
This query ranks the top industries by total layoffs each year.
```sql
WITH Industry_Year (industry, years, laid_off_total) AS (
    SELECT industry, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging_2
    WHERE `date` IS NOT NULL AND total_laid_off IS NOT NULL
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
```

---

## **Conclusion**
This set of SQL queries provides a comprehensive approach to data cleaning and exploratory data analysis for global layoffs. By aggregating data across multiple dimensions—companies, industries, countries, and time periods—insights into global workforce trends can be derived, helping stakeholders make informed decisions.

