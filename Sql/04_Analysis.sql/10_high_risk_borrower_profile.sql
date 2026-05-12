-- ============================================================
-- Script:  10_high_risk_borrower_profile.sql
-- Purpose: Compare profile of defaulted vs fully paid borrowers
-- Fixed:   Join dim_borrower via loan_id
-- ============================================================

USE lending_club_db;

WITH borrower_segments AS (
    SELECT
        f.loan_id,
        f.loan_status,
        f.is_defaulted,
        d.grade,
        d.int_rate,
        d.loan_amnt,
        d.purpose,
        d.term,
        b.emp_length,
        b.home_ownership,
        b.annual_inc,
        c.fico_range_low,
        c.dti,
        c.delinq_2yrs,
        c.pub_rec,
        c.revol_util,
        c.open_acc,
        c.mort_acc
    FROM fact_loan_performance f
    JOIN dim_loan_details d     ON f.loan_id = d.loan_id
    JOIN dim_borrower b         ON f.loan_id = b.loan_id
    JOIN fact_credit_profile c  ON f.loan_id = c.loan_id
    WHERE f.is_concluded = 1
),
profile_comparison AS (
    SELECT
        CASE
            WHEN is_defaulted = 1 THEN 'Defaulted'
            ELSE 'Fully Paid'
        END                                                     AS borrower_segment,
        COUNT(*)                                                AS total_borrowers,
        ROUND(AVG(fico_range_low), 0)                           AS avg_fico_score,
        ROUND(AVG(dti), 2)                                      AS avg_dti,
        ROUND(AVG(annual_inc), 2)                               AS avg_annual_income,
        ROUND(AVG(loan_amnt), 2)                                AS avg_loan_amount,
        ROUND(AVG(int_rate), 2)                                 AS avg_interest_rate,
        ROUND(AVG(revol_util), 2)                               AS avg_revolving_utilisation,
        ROUND(AVG(delinq_2yrs), 2)                              AS avg_delinquencies_2yrs,
        ROUND(AVG(pub_rec), 2)                                  AS avg_public_records,
        ROUND(AVG(open_acc), 2)                                 AS avg_open_accounts,
        ROUND(AVG(mort_acc), 2)                                 AS avg_mortgage_accounts
    FROM borrower_segments
    GROUP BY borrower_segment
)
SELECT *
FROM profile_comparison
ORDER BY borrower_segment DESC;