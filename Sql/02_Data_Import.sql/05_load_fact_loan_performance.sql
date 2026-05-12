-- =============================================================
-- Script:  05_load_fact_loan_performance.sql
-- Purpose: Populate fact_loan_performance table
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/05/2026
-- =============================================================

INSERT INTO fact_loan_performance (
    loan_id, loan_status, out_prncp, out_prncp_inv,
    total_pymnt, total_pymnt_inv, total_rec_prncp,
    total_rec_int, total_rec_late_fee, recoveries,
    collection_recovery_fee, last_pymnt_d, last_pymnt_amnt,
    next_pymnt_d, last_credit_pull_d, pymnt_plan
)
SELECT 
    id,
    loan_status,
    NULLIF(out_prncp, '') + 0,
    NULLIF(out_prncp_inv, '') + 0,
    NULLIF(total_pymnt, '') + 0,
    NULLIF(total_pymnt_inv, '') + 0,
    NULLIF(total_rec_prncp, '') + 0,
    NULLIF(total_rec_int, '') + 0,
    NULLIF(total_rec_late_fee, '') + 0,
    NULLIF(recoveries, '') + 0,
    NULLIF(collection_recovery_fee, '') + 0,
    -- Handle last_pymnt_d
    CASE 
        WHEN last_pymnt_d IS NOT NULL AND last_pymnt_d != '' 
        THEN STR_TO_DATE(CONCAT('01-', last_pymnt_d), '%d-%b-%Y') 
        ELSE NULL 
    END,
    NULLIF(last_pymnt_amnt, '') + 0,
    -- Handle next_pymnt_d
    CASE 
        WHEN next_pymnt_d IS NOT NULL AND next_pymnt_d != '' 
        THEN STR_TO_DATE(CONCAT('01-', next_pymnt_d), '%d-%b-%Y') 
        ELSE NULL 
    END,
    -- Handle last_credit_pull_d
    CASE 
        WHEN last_credit_pull_d IS NOT NULL AND last_credit_pull_d != '' 
        THEN STR_TO_DATE(CONCAT('01-', last_credit_pull_d), '%d-%b-%Y') 
        ELSE NULL 
    END,
    pymnt_plan
FROM stg_accepted_loans
-- To filter out the completely empty rows/footers
WHERE id IS NOT NULL AND id != '';