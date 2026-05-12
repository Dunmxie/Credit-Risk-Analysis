-- ============================================================
-- Script:  07_default_rate_by_purpose.sql
-- Purpose: Analyse which loan purposes carry most risk
-- Business Question: What are borrowers using loans for
--                    and which purposes end in default?
-- ============================================================

USE lending_club_db;

SELECT
    d.purpose,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate,
    ROUND(SUM(d.loan_amnt), 2)                                  AS total_portfolio_value
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
WHERE d.purpose IS NOT NULL
  AND d.purpose != ''
GROUP BY d.purpose
ORDER BY concluded_default_rate_pct DESC;