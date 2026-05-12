-- =============================================================
-- Script:  09_load_dim_date.sql
-- Purpose: Populate dim_date table
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/05/2026
-- =============================================================

SET SESSION cte_max_recursion_depth = 5000;

INSERT INTO dim_date (date_id, full_date, day, month, month_name, quarter, year, day_of_week, day_name, is_weekend)
WITH RECURSIVE date_series AS (
    SELECT DATE('2007-01-01') AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM date_series
    WHERE dt < '2019-12-31'
)
SELECT
    DATE_FORMAT(dt, '%Y%m%d') AS date_id,
    dt AS full_date,
    DAY(dt) AS day,
    MONTH(dt) AS month,
    MONTHNAME(dt) AS month_name,
    QUARTER(dt) AS quarter,
    YEAR(dt) AS year,
    DAYOFWEEK(dt) AS day_of_week,
    DAYNAME(dt) AS day_name,
    CASE WHEN DAYOFWEEK(dt) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_series;