-- =============================================================
-- Script:  06_load_fact_credit_profile.sql
-- Purpose: Populate fact_credit_profile table
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/05/2026
-- =============================================================

INSERT INTO fact_credit_profile (
    loan_id, fico_range_low, fico_range_high,
    last_fico_range_low, last_fico_range_high,
    dti, delinq_2yrs, earliest_cr_line, inq_last_6mths,
    mths_since_last_delinq, mths_since_last_record,
    open_acc, pub_rec, revol_bal, revol_util,
    total_acc, acc_now_delinq, tot_coll_amt,
    tot_cur_bal, tot_hi_cred_lim, total_bal_ex_mort,
    total_bc_limit, pub_rec_bankruptcies, tax_liens,
    mort_acc, num_actv_bc_tl, num_actv_rev_tl,
    num_bc_sats, num_bc_tl, num_il_tl, num_op_rev_tl,
    num_rev_accts, num_sats, pct_tl_nvr_dlq,
    percent_bc_gt_75, bc_util, avg_cur_bal,
    num_accts_ever_120_pd, num_tl_90g_dpd_24m,
    chargeoff_within_12_mths, delinq_amnt
)
SELECT 
    id,
    NULLIF(fico_range_low, '') + 0,
    NULLIF(fico_range_high, '') + 0,
    NULLIF(last_fico_range_low, '') + 0,
    NULLIF(last_fico_range_high, '') + 0,
    NULLIF(dti, '') + 0,
    NULLIF(delinq_2yrs, '') + 0,
    -- SAFE DATE CONVERSION
    CASE 
        WHEN earliest_cr_line IS NOT NULL AND earliest_cr_line != '' 
        THEN STR_TO_DATE(CONCAT('01-', earliest_cr_line), '%d-%b-%Y') 
        ELSE NULL 
    END,
    NULLIF(inq_last_6mths, '') + 0,
    NULLIF(mths_since_last_delinq, '') + 0,
    NULLIF(mths_since_last_record, '') + 0,
    NULLIF(open_acc, '') + 0,
    NULLIF(pub_rec, '') + 0,
    NULLIF(revol_bal, '') + 0,
    REPLACE(NULLIF(revol_util, ''), '%', '') + 0,
    NULLIF(total_acc, '') + 0,
    NULLIF(acc_now_delinq, '') + 0,
    NULLIF(tot_coll_amt, '') + 0,
    NULLIF(tot_cur_bal, '') + 0,
    NULLIF(tot_hi_cred_lim, '') + 0,
    NULLIF(total_bal_ex_mort, '') + 0,
    NULLIF(total_bc_limit, '') + 0,
    NULLIF(pub_rec_bankruptcies, '') + 0,
    NULLIF(tax_liens, '') + 0,
    NULLIF(mort_acc, '') + 0,
    NULLIF(num_actv_bc_tl, '') + 0,
    NULLIF(num_actv_rev_tl, '') + 0,
    NULLIF(num_bc_sats, '') + 0,
    NULLIF(num_bc_tl, '') + 0,
    NULLIF(num_il_tl, '') + 0,
    NULLIF(num_op_rev_tl, '') + 0,
    NULLIF(num_rev_accts, '') + 0,
    NULLIF(num_sats, '') + 0,
    NULLIF(pct_tl_nvr_dlq, '') + 0,
    NULLIF(percent_bc_gt_75, '') + 0,
    NULLIF(bc_util, '') + 0,
    NULLIF(avg_cur_bal, '') + 0,
    NULLIF(num_accts_ever_120_pd, '') + 0,
    NULLIF(num_tl_90g_dpd_24m, '') + 0,
    NULLIF(chargeoff_within_12_mths, '') + 0,
    NULLIF(delinq_amnt, '') + 0
FROM stg_accepted_loans
WHERE id IS NOT NULL AND id != '';