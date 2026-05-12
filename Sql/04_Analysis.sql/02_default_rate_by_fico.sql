-- ============================================================
-- Script:  02_default_rate_by_fico.sql
-- Purpose: Group borrowers into FICO bands and compare
--          default rates across credit score ranges
-- Business Question: How does credit score predict default?
-- ============================================================

USE lending_club_db;

SELECT
    -- Create meaningful FICO score bands
    CASE
        WHEN c.fico_range_low >= 800 THEN '800+ Exceptional'
        WHEN c.fico_range_low >= 740 THEN '740-799 Very Good'
        WHEN c.fico_range_low >= 670 THEN '670-739 Good'
        WHEN c.fico_range_low >= 580 THEN '580-669 Fair'
        WHEN c.fico_range_low >= 300 THEN '300-579 Poor'
        ELSE 'Unknown'
    END                                                         AS fico_band,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(AVG(c.fico_range_low), 0)                             AS avg_fico_score,
    -- Default rate among concluded loans
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate_pct
FROM fact_loan_performance f
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
WHERE c.fico_range_low IS NOT NULL
GROUP BY fico_band
ORDER BY avg_fico_score DESC;