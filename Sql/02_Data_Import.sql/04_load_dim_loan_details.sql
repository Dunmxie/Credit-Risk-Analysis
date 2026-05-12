-- =============================================================
-- Script:  04_load_dim_loan_details.sql
-- Purpose: Populate dim_loan_details table
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/05/2026
-- =============================================================


INSERT INTO dim_loan_details (
    loan_id, loan_amnt, funded_amnt, funded_amnt_inv,
    term, int_rate, installment, grade, sub_grade,
    purpose, title, issue_d, initial_list_status,
    disbursement_method, policy_code
)
SELECT 
    id,
    NULLIF(loan_amnt, '') + 0,
    NULLIF(funded_amnt, '') + 0,
    NULLIF(funded_amnt_inv, '') + 0,
    TRIM(term),
    REPLACE(NULLIF(int_rate, ''), '%', '') + 0,
    NULLIF(installment, '') + 0,
    grade,
    sub_grade,
    purpose,
    title,
    STR_TO_DATE(CONCAT('01-', issue_d), '%d-%b-%Y'),
    initial_list_status,
    disbursement_method,
    policy_code
FROM stg_accepted_loans
-- This prevents the '01-' error by ignoring rows with no date
WHERE issue_d IS NOT NULL 
  AND issue_d != '' 
  AND issue_d != ' ';