-- ============================================================
-- Script:  01_default_rate_by_grade.sql
-- Purpose: Calculate default rate for each loan grade
-- Business Question: Which grades carry the highest risk?
-- ============================================================

USE lending_club_db;

SELECT
    d.grade,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_concluded)                                         AS concluded_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(SUM(f.is_defaulted) * 100.0 / COUNT(*), 2)           AS overall_default_rate_pct,

    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
WHERE d.grade IS NOT NULL
GROUP BY d.grade
ORDER BY d.grade;