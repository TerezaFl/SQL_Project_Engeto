/*
 * 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?
 * Pokud HDP vzroste výrazněji, projeví se to na cenách potravin či mzdách?
 */

-- VIEW: HDP v ČR v letech 2006–2018
CREATE OR REPLACE VIEW v_tereza_flekova_gdp_national_2006_2018 AS 
SELECT * 
FROM t_tereza_flekova_project_sql_secondary_final
WHERE country = 'Czech Republic';


-- VIEW: Meziroční změna HDP (v %)
CREATE OR REPLACE VIEW v_tereza_flekova_trend_gdp_growth_2006_2018 AS 
SELECT 
    older.year AS older_year,
    older.GDP AS older_gdp,
    newer.year AS newer_year,
    newer.GDP AS newer_gdp,
    ROUND(((newer.GDP - older.GDP) / older.GDP * 100)::numeric, 2) AS gdp_growth_percentage
FROM v_tereza_flekova_gdp_national_2006_2018 AS older
JOIN v_tereza_flekova_gdp_national_2006_2018 AS newer 
    ON newer.year = older.year + 1;

SELECT *
FROM v_tereza_flekova_trend_gdp_growth_2006_2018;


-- VIEW: Kombinovaný meziroční vývoj cen potravin, mezd a HDP
CREATE OR REPLACE VIEW v_tereza_flekova_trend_combined_foodprice_wages_gdp_2006_2018 AS 
SELECT 
    gdp.older_year,
    gdp.newer_year,
    food.food_price_growth_percentage AS avg_price_diff_percentage, 
    wages.wage_growth_percentage AS avg_wages_diff_percentage, 
    gdp.gdp_growth_percentage
FROM v_tereza_flekova_trend_gdp_growth_2006_2018 AS gdp
JOIN v_tereza_flekova_trend_wages_growth_2006_2018 AS wages 
    ON wages.older_year = gdp.older_year
JOIN v_tereza_flekova_trend_food_price_growth_2006_2018 AS food 
    ON food.older_year = gdp.older_year;

SELECT *
FROM v_tereza_flekova_trend_combined_foodprice_wages_gdp_2006_2018;


-- Kumulativní růst za celé období
CREATE OR REPLACE VIEW v_tereza_flekova_trend_combined_foodprice_wages_gdp_2006_2018 AS 
SELECT 
    gdp.older_year,
    gdp.newer_year,
    food.food_price_growth_percentage AS avg_price_diff_percentage, 
    wages.wage_growth_percentage AS avg_wages_diff_percentage, 
    gdp.gdp_growth_percentage
FROM v_tereza_flekova_trend_gdp_growth_2006_2018 AS gdp
JOIN v_tereza_flekova_trend_wages_growth_2006_2018 AS wages 
    ON wages.older_year = gdp.older_year
JOIN v_tereza_flekova_trend_food_price_growth_2006_2018 AS food 
    ON food.older_year = gdp.older_year;

SELECT *
FROM v_tereza_flekova_trend_combined_foodprice_wages_gdp_2006_2018;

-- Průměrný meziroční růst za celé období
SELECT 
    MIN(older_year) AS year_from,
    MAX(newer_year) AS year_to,
    ROUND(AVG(avg_price_diff_percentage), 2) AS avg_food_price_growth_percent,
    ROUND(AVG(avg_wages_diff_percentage), 2) AS avg_wages_growth_percent,
    ROUND(AVG(gdp_growth_percentage), 2) AS avg_gdp_growth_percent
FROM v_tereza_flekova_trend_combined_foodprice_wages_gdp_2006_2018;

-- Celkový růst za celé období
SELECT 
    MIN(older_year) AS year_from,
    MAX(newer_year) AS year_to,
    ROUND(SUM(avg_price_diff_percentage), 2) AS total_food_price_growth_percent,
    ROUND(SUM(avg_wages_diff_percentage), 2) AS total_wages_growth_percent,
    ROUND(SUM(gdp_growth_percentage), 2) AS total_gdp_growth_percent
FROM v_tereza_flekova_trend_combined_foodprice_wages_gdp_2006_2018;