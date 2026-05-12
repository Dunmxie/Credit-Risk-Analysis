-- ============================================================
-- Script:  08_default_rate_by_employment.sql
-- Purpose: Analyse how job stability relates to default risk
-- Fixed:   Join dim_borrower via loan_id
-- ============================================================

USE lending_club_db;

SELECT
    b.emp_length,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(c.dti), 2)                                        AS avg_dti,
    ROUND(AVG(c.fico_range_low), 0)                             AS avg_fico_score
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
JOIN dim_borrower b
    ON f.loan_id = b.loan_id
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
GROUP BY b.emp_length
ORDER BY concluded_default_rate_pct DESC;