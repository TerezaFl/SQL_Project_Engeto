/*
 * 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
 * Analýza vývoje průměrných mezd v jednotlivých odvětvích
 */

-- Vytvoření přehledu průměrných mezd podle odvětví a roku
CREATE OR REPLACE VIEW v_tereza_flekova_project_wage_trend_by_sector AS
SELECT 
	industry_branch,
	payroll_year,
	round(avg(avg_wages)) AS avg_wages_CZK
FROM t_tereza_flekova_project_SQL_primary_final
GROUP BY industry_branch, payroll_year 
ORDER BY industry_branch;

SELECT *
FROM v_tereza_flekova_project_wage_trend_by_sector;


-- Vytvoření přehledu meziročního vývoje mezd a trendu
CREATE OR REPLACE VIEW v_tereza_flekova_project_wage_development_by_sector AS
SELECT
	n.industry_branch AS current_branch,
	o.payroll_year AS previous_year,
	o.avg_wages_CZK AS wages_prev_year,
	n.payroll_year AS current_year,
	n.avg_wages_CZK AS wages_current,
	n.avg_wages_CZK - o.avg_wages_CZK AS wage_diff_czk,
	ROUND(n.avg_wages_CZK * 100.0 / o.avg_wages_CZK - 100, 2) AS wage_diff_percent,
	CASE
		  WHEN newer.avg_wages_CZK > older.avg_wages_CZK THEN 'UP'
          WHEN newer.avg_wages_CZK < older.avg_wages_CZK THEN 'DOWN'
          ELSE 'SAME'
	END AS trend
FROM v_tereza_flekova_project_wage_trend_by_sector AS newer_avg
JOIN v_tereza_flekova_project_wage_trend_by_sector AS older_avg 
	ON n.industry_branch = o.industry_branch
	AND n.payroll_year = o.payroll_year + 1
ORDER BY n.industry_branch;

-- Výpis obsahu obou pohledů
SELECT * 
FROM v_tereza_flekova_project_wage_trend_by_sector;

SELECT * 
FROM v_tereza_flekova_wage_development_by_sector;

-- Identifikace meziročního poklesu mezd
SELECT *
FROM v_tereza_flekova_wage_development_by_sector
WHERE wages_trend = 'DOWN'
ORDER BY wages_difference_percentage;

-- Porovnání mezd v letech 2006 a 2018 podle odvětví a výpočet celkového růstu
SELECT *
FROM v_tereza_flekova_project_wage_trend_by_sector
WHERE payroll_year IN (2006, 2018);

-- Výpočet rozdílu mezd mezi lety 2006 a 2018
SELECT
	o.industry_branch,
	o.payroll_year AS year_2006,
	o.avg_wages_CZK AS wage_2006,
	n.payroll_year AS year_2018,
	n.avg_wages_CZK AS wage_2018,
	n.avg_wages_CZK - o.avg_wages_CZK AS diff_czk,
	ROUND(n.avg_wages_CZK * 100.0 / o.avg_wages_CZK - 100, 2) AS diff_percent
FROM v_tereza_flekova_project_wage_trend_by_sector n
JOIN v_tereza_flekova_project_wage_trend_by_sector o 
	ON n.industry_branch = o.industry_branch
WHERE o.payroll_year = 2006 
	AND n.payroll_year = 2018
ORDER BY round(n.avg_wages_CZK * 100 / o.avg_wages_CZK, 2) - 100 DESC;