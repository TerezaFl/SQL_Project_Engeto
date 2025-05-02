/*
 * 4. Je některý rok, kdy růst cen potravin výrazně předběhl růst mezd (o více než 10 %)?
 */

-- Výchozí tabulka s průměrnými mzdami podle odvětví a roku

SELECT * 
FROM v_tereza_flekova_project_wage_trend_by_sector;

-- VIEW: Celkový průměr mezd v ČR napříč odvětvími (2006–2018)

CREATE OR REPLACE VIEW v_tereza_flekova_avg_wages_national_2006_2018 AS 
SELECT 
	industry_branch, 
	payroll_year, 
	ROUND(AVG(avg_wages_CZK)) AS avg_wages_cr_czk
FROM v_tereza_flekova_project_wage_trend_by_sector
GROUP BY payroll_year, industry_branch;

SELECT * 
FROM v_tereza_flekova_avg_wages_national_2006_2018;

-- VIEW: Meziroční změna průměrné mzdy v ČR (2006–2018)

CREATE OR REPLACE VIEW v_tereza_flekova_trend_wages_growth_2006_2018 AS 
SELECT
	older.payroll_year AS older_year, 
	older.avg_wages_cr_czk AS older_wages,
	newer.payroll_year AS newer_year,
	newer.avg_wages_cr_czk AS newer_wages,
	ROUND((newer.avg_wages_cr_czk - older.avg_wages_cr_czk) / older.avg_wages_cr_czk * 100, 2) AS wage_growth_percentage
FROM v_tereza_flekova_avg_wages_national_2006_2018 AS older
JOIN v_tereza_flekova_avg_wages_national_2006_2018 AS newer
	ON newer.industry_branch = older.industry_branch 
	AND newer.payroll_year = older.payroll_year + 1;

SELECT * 
FROM v_tereza_flekova_trend_wages_growth_2006_2018;

-- VIEW: Průměrná cena potravin napříč kategoriemi (2006–2018)

CREATE OR REPLACE VIEW v_tereza_flekova_avg_food_price_national_2006_2018 AS 
SELECT 
	food_category,  
	year,
	ROUND(AVG(avg_price), 2) AS avg_food_price_cr_czk
FROM v_tereza_flekova_avg_price_by_year
GROUP BY year, food_category;

SELECT * 
FROM v_tereza_flekova_avg_food_price_national_2006_2018;

-- VIEW: Meziroční změna průměrných cen potravin (2006–2018)

CREATE OR REPLACE VIEW v_tereza_flekova_trend_food_price_growth_2006_2018 AS 
SELECT 
	older.year AS older_year, 
	older.avg_food_price_cr_czk AS older_price, 
	newer.year AS newer_year, 
	newer.avg_food_price_cr_czk AS newer_price,
	newer.avg_food_price_cr_czk - older.avg_food_price_cr_czk AS price_growth_czk,
	ROUND((newer.avg_food_price_cr_czk - older.avg_food_price_cr_czk) / older.avg_food_price_cr_czk * 100, 2) AS food_price_growth_percentage
FROM v_tereza_flekova_avg_food_price_national_2006_2018 AS older
JOIN v_tereza_flekova_avg_food_price_national_2006_2018 AS newer 
	ON newer.food_category = older.food_category
	AND newer.year = older.year + 1;

-- VIEW: Srovnání meziročního růstu mezd a cen potravin
CREATE OR REPLACE VIEW v_tereza_flekova_comparison_yoy_growth_prices_vs_wages AS 
SELECT 
	fp.older_year, 
	wg.newer_year,
	wg.wage_growth_percentage,
	fp.food_price_growth_percentage,
	fp.food_price_growth_percentage - wg.wage_growth_percentage AS diff_prices_vs_wages
FROM v_tereza_flekova_trend_food_price_growth_2006_2018 AS fp
JOIN v_tereza_flekova_trend_wages_growth_2006_2018 AS wg
	ON wg.older_year = fp.older_year
GROUP BY fp.older_year, wg.newer_year, wg.wage_growth_percentage, fp.food_price_growth_percentage
ORDER BY diff_prices_vs_wages DESC;

-- Výsledný přehled s porovnáním

SELECT * 
FROM v_tereza_flekova_comparison_yoy_growth_prices_vs_wages
ORDER BY diff_prices_vs_wages DESC;
