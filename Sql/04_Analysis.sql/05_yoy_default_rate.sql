-- ============================================================
-- Script:  05_yoy_default_rate.sql
-- Purpose: Track how default rate changed each year
-- Fixed:   Removed dim_date join, extract year directly
--          from issue_d in dim_loan_details
-- ============================================================

USE lending_club_db;

WITH yearly_stats AS (
    SELECT
        YEAR(d.issue_d)                                         AS issue_year,
        COUNT(*)                                                AS total_loans,
        SUM(f.is_defaulted)                                     AS defaulted_loans,
        SUM(f.is_concluded)                                     AS concluded_loans,
        ROUND(
            SUM(f.is_defaulted) * 100.0 /
            NULLIF(SUM(f.is_concluded), 0), 2
        )                                                       AS default_rate_pct,
        ROUND(SUM(d.loan_amnt), 2)                              AS total_loan_value
    FROM fact_loan_performance f
    JOIN dim_loan_details d
        ON f.loan_id = d.loan_id
    WHERE d.issue_d IS NOT NULL
    GROUP BY issue_year
)
SELECT
    issue_year,
    total_loans,
    concluded_loans,
    defaulted_loans,
    default_rate_pct,
    total_loan_value,
    ROUND(
        default_rate_pct - LAG(default_rate_pct)
        OVER (ORDER BY issue_year), 2
    )                                                           AS yoy_default_rate_change
FROM yearly_stats
ORDER BY issue_year;