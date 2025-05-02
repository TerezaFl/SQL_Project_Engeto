
/*
 * 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší procentuální meziroční nárůst)?
 */

-- VIEW: Přehled průměrných cen potravin podle roku
CREATE OR REPLACE VIEW v_tereza_flekova_avg_price_by_year AS 
SELECT 
	food_category,
	price_value AS value, 
	price_unit AS unit, 
	payroll_year AS year, 
	ROUND(AVG(price)::numeric, 2) AS avg_price
FROM t_tereza_flekova_project_sql_primary_final
GROUP BY food_category, payroll_year, price_value, price_unit;

-- Náhled na průměrné roční ceny potravin
SELECT *
FROM v_tereza_flekova_avg_price_by_year;

-- VIEW: Meziroční vývoj cen potravin
CREATE OR REPLACE VIEW v_tereza_flekova_yearly_price_trend AS 
SELECT 
	older.food_category, 
	older.value,
	older.unit,
	older.year AS older_year,
	older.avg_price AS older_price,
	newer.year AS newer_year,
	newer.avg_price AS newer_price, 
	newer.avg_price - older.avg_price AS price_diff_czk,
	ROUND(((newer.avg_price - older.avg_price) / older.avg_price * 100)::numeric, 2) AS price_diff_percentage,
	CASE
		WHEN newer.avg_price > older.avg_price THEN 'up'
		ELSE 'down'
	END AS price_trend
FROM v_tereza_flekova_avg_price_by_year AS older
JOIN v_tereza_flekova_avg_price_by_year AS newer 
	ON older.food_category = newer.food_category
	AND newer.year = older.year + 1
ORDER BY food_category, older.year;

-- Náhled vývoje cen mezi lety
SELECT * 
FROM v_tereza_flekova_yearly_price_trend;

-- Průměrný roční nárůst cen mezi 2006–2018
SELECT 
	older_year AS year_from,
	MAX(newer_year) AS year_to,
	food_category,
	ROUND(AVG(price_diff_percentage)::numeric, 2) AS avg_annual_price_growth_in_percentage
FROM v_tereza_flekova_yearly_price_trend
GROUP BY food_category, older_year
ORDER BY avg_annual_price_growth_in_percentage;

-- Nejvyšší zaznamenaný meziroční nárůst cen
SELECT * 
FROM v_tereza_flekova_yearly_price_trend
ORDER BY price_diff_percentage DESC;

-- Nejnižší nebo záporný meziroční růst cen
SELECT * 
FROM v_tereza_flekova_yearly_price_trend
ORDER BY price_diff_percentage ASC;

-- VIEW: Porovnání průměrných cen v roce 2006 a 2018
CREATE OR REPLACE VIEW v_tereza_flekova_price_comparison_2006_2018 AS 
SELECT 
	older.food_category,
	older.value,
	older.unit,
	older.year AS older_year,
	older.avg_price AS older_price,
	newer.year AS newer_year,
	newer.avg_price AS newer_price,
	newer.avg_price - older.avg_price AS price_diff_czk,
	ROUND(((newer.avg_price - older.avg_price) / older.avg_price * 100)::numeric, 2) AS price_diff_percentage
FROM v_tereza_flekova_avg_price_by_year AS older
JOIN v_tereza_flekova_avg_price_by_year AS newer
	ON older.food_category = newer.food_category
WHERE older.year = 2006 AND newer.year = 2018;

-- Výpis srovnání cen z roku 2006 a 2018
SELECT * 
FROM v_tereza_flekova_price_comparison_2006_2018
ORDER BY price_diff_percentage DESC;
