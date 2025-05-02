/*
 * TABULKA 2 - Makroekonomické ukazatele evropských států (HDP, GINI, populace) pro roky 2006–2018
 */

CREATE OR REPLACE TABLE t_tereza_flekova_project_SQL_secondary_final AS 
SELECT 
	c.country,
	e.`year`,
	e.population,
	e.gini,
	e.GDP
FROM countries c
JOIN economies e 
	ON c.country = e.country
WHERE c.continent = 'Europe'
	AND e.`year` BETWEEN 2006 AND 2018
ORDER BY c.country, e.`year`;

SELECT *
FROM t_tereza_flekova_project_sql_secondary_final;
