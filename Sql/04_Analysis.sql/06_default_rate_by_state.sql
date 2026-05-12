-- ============================================================
-- Script:  06_default_rate_by_state.sql
-- Purpose: Identify which states have highest default rates
-- Fixed:   Join dim_borrower via loan_id
-- ============================================================

USE lending_club_db;

SELECT
    b.addr_state                                                AS state,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(c.fico_range_low), 0)                             AS avg_fico_score,
    ROUND(AVG(c.dti), 2)                                        AS avg_dti
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
JOIN dim_borrower b
    ON f.loan_id = b.loan_id
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
WHERE b.addr_state IS NOT NULL
  AND b.addr_state != ''
GROUP BY b.addr_state
HAVING COUNT(*) > 1000
ORDER BY concluded_default_rate_pct DESC;