-- =============================================================
-- Script:  08_dim_date.sql
-- Purpose: A calendar table essential for Power BI time intelligence
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/5/2026
-- =============================================================

CREATE TABLE dim_date (
    date_id       INT PRIMARY KEY,
    full_date     DATE,
    day           INT,
    month         INT,
    month_name    VARCHAR(20),
    quarter       INT,
    year          INT,
    day_of_week   INT,
    day_name      VARCHAR(20),
    is_weekend    BOOLEAN
);