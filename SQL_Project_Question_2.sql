/*
 * 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 */

--Kupní síla v roce 2006 a 2018 pro celou ČR (chléb a mléko)
SELECT
	food_category,
	price_value,
	price_unit,
	payroll_year,
	ROUND(AVG(price)::numeric, 2) AS avg_price,
	ROUND(AVG(avg_wages)::numeric, 2) AS avg_wages,
	ROUND((AVG(avg_wages) / AVG(price))::numeric) AS avg_purchasing_power
FROM t_tereza_flekova_project_sql_primary_final
WHERE payroll_year IN (2006, 2018)
  AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY food_category, payroll_year, price_value, price_unit;

--Kupní síla podle odvětví (včetně chleba a mléka)
SELECT
	industry_branch,
	food_category,
	price_value,
	price_unit,
	payroll_year,
	ROUND(AVG(price)::numeric, 2) AS avg_price,
	ROUND(AVG(avg_wages)::numeric, 2) AS avg_wages,
	ROUND((AVG(avg_wages) / AVG(price))::numeric) AS avg_purchasing_power
FROM t_tereza_flekova_project_sql_primary_final
WHERE payroll_year IN (2006, 2018)
  AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY industry_branch, food_category, payroll_year, price_value, price_unit;

--Kupní síla seřazená podle hodnoty (odvětví a kategorie potraviny)
SELECT
	food_category,
	price_value,
	price_unit,
	payroll_year,
	ROUND(AVG(price)::numeric, 2) AS avg_price,
	ROUND(AVG(avg_wages)::numeric, 2) AS avg_wages,
	ROUND((AVG(avg_wages) / AVG(price))::numeric) AS avg_purchasing_power,
	industry_branch
FROM t_tereza_flekova_project_sql_primary_final
WHERE payroll_year IN (2006, 2018)
  AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY food_category, payroll_year, industry_branch, price_value, price_unit
ORDER BY avg_purchasing_power DESC;
