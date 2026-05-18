-- ============================================================
-- Script:  09_financial_loss_analysis.sql
-- Purpose: Quantify the actual financial impact of defaults
-- Business Question: How much money has been lost to defaults?
-- ============================================================

USE lending_club_db;

WITH loss_summary AS (
    SELECT
        d.grade,
        d.purpose,
        YEAR(d.issue_d)                                         AS issue_year,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN d.funded_amnt ELSE 0 END)                      AS total_funded_to_defaulters,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN f.total_rec_prncp ELSE 0 END)                  AS total_recovered,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN d.funded_amnt - f.total_rec_prncp ELSE 0 END)  AS net_loss,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN f.total_rec_late_fee ELSE 0 END)               AS late_fees_collected,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN f.recoveries ELSE 0 END)                       AS collection_recoveries,
        COUNT(CASE WHEN f.is_defaulted = 1
            THEN 1 END)                                         AS defaulted_loan_count
    FROM fact_loan_performance f
    JOIN dim_loan_details d
        ON f.loan_id = d.loan_id
    GROUP BY
        d.grade,
        d.purpose,
        issue_year
)
SELECT
    grade,
    purpose,
    issue_year,
    defaulted_loan_count,
    ROUND(total_funded_to_defaulters, 2)                        AS total_funded_to_defaulters,
    ROUND(total_recovered, 2)                                   AS total_recovered,
    ROUND(net_loss, 2)                                          AS net_loss,
    ROUND(late_fees_collected, 2)                               AS late_fees_collected,
    ROUND(collection_recoveries, 2)                             AS collection_recoveries,
    ROUND(
        net_loss * 100.0 /
        NULLIF(total_funded_to_defaulters, 0), 2
    )                                                           AS loss_rate_pct
FROM loss_summary
WHERE defaulted_loan_count > 0
ORDER BY net_loss DESC;