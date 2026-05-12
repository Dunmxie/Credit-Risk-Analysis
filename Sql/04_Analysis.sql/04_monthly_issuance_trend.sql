-- ============================================================
-- Script:  04_monthly_issuance_trend.sql
-- Purpose: Track loan volume and value growth over time
-- Fixed:   Extract date parts directly from issue_d
-- ============================================================

USE lending_club_db;

SELECT
    YEAR(d.issue_d)                                             AS issue_year,
    MONTH(d.issue_d)                                            AS issue_month,
    MONTHNAME(d.issue_d)                                        AS month_name,
    COUNT(*)                                                    AS loans_issued,
    ROUND(SUM(d.loan_amnt), 2)                                  AS total_loan_value,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate
FROM dim_loan_details d
JOIN fact_loan_performance f
    ON d.loan_id = f.loan_id
WHERE d.issue_d IS NOT NULL
GROUP BY
    issue_year,
    issue_month,
    month_name
ORDER BY
    issue_year,
    issue_month;