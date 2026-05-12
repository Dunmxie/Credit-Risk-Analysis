-- ============================================================
-- Script:  03_default_rate_by_dti.sql
-- Purpose: Group borrowers into DTI bands and analyse
--          how debt burden relates to default risk
-- Business Question: Does high DTI predict default?
-- ============================================================

USE lending_club_db;

SELECT
    CASE
        WHEN c.dti IS NULL          THEN 'Unknown'
        WHEN c.dti < 10             THEN '0-9% Low'
        WHEN c.dti BETWEEN 10 AND 19 THEN '10-19% Moderate'
        WHEN c.dti BETWEEN 20 AND 29 THEN '20-29% High'
        WHEN c.dti BETWEEN 30 AND 39 THEN '30-39% Very High'
        WHEN c.dti >= 40            THEN '40%+ Extreme'
    END                                                         AS dti_band,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(AVG(c.dti), 2)                                        AS avg_dti,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount
FROM fact_loan_performance f
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
GROUP BY dti_band
ORDER BY avg_dti;