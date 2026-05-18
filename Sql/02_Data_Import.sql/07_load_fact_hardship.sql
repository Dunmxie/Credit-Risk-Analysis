-- =============================================================
-- Script:  07_load_fact_hardship.sql
-- Purpose: Populate fact_hardship table
-- =============================================================

INSERT INTO fact_hardship (
    loan_id, hardship_flag, hardship_type, hardship_reason,
    hardship_status, deferral_term, hardship_amount,
    hardship_start_date, hardship_end_date, hardship_length,
    hardship_dpd, hardship_loan_status,
    orig_projected_additional_accrued_interest,
    hardship_payoff_balance_amount,
    hardship_last_payment_amount, payment_plan_start_date
)
SELECT
    id,
    hardship_flag,
    hardship_type,
    hardship_reason,
    hardship_status,
    NULLIF(deferral_term, '') + 0,
    NULLIF(hardship_amount, '') + 0,
    STR_TO_DATE(CONCAT('01-', hardship_start_date), '%d-%b-%Y'),
    STR_TO_DATE(CONCAT('01-', hardship_end_date), '%d-%b-%Y'),
    NULLIF(hardship_length, '') + 0,
    NULLIF(hardship_dpd, '') + 0,
    hardship_loan_status,
    NULLIF(orig_projected_additional_accrued_interest, '') + 0,
    NULLIF(hardship_payoff_balance_amount, '') + 0,
    NULLIF(hardship_last_payment_amount, '') + 0,
    STR_TO_DATE(CONCAT('01-', payment_plan_start_date), '%d-%b-%Y')
FROM stg_accepted_loans
WHERE hardship_flag = 'Y';