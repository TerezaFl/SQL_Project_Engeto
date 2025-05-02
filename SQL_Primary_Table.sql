/*
 * TABULKA 1 - Sloučení dat o cenách potravin a mzdách v ČR pro období 2006–2018
 */

CREATE OR REPLACE TABLE t_tereza_flekova_project_SQL_primary_final AS 
SELECT 
	cpc.name AS food_category,
	cpc.price_value,
	cpc.price_unit,
	cp.value AS price,
	cp.date_from,
	cp.date_to,
	cpay.payroll_year,
	cpay.value AS avg_wages,
	cpib.name AS industry_branch
FROM czechia_price cp
JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code 
JOIN czechia_payroll cpay 
	ON YEAR(cp.date_from) = cpay.payroll_year
	AND cp.region_code IS NULL
	AND cpay.value_type_code = 5958
JOIN czechia_payroll_industry_branch cpib 
	ON cpib.code = cpay.industry_branch_code;

SELECT *
FROM t_tereza_flekova_project_sql_primary_final
ORDER BY date_from, food_category;