-- ============================================================
-- MASTER SCRIPT 02 — DATA IMPORT
-- Project:  Credit Risk Analytics
-- Author:   Oluwadunmininu Deorah Oluremi
-- Date:     10/05/2026
-- 
-- Description:
--   Loads data into the lending_club_db schema and all 9 tables
--   including the staging table, dimension tables, and fact
--   tables.
--
-- Tables Loaded:
--   1. stg_accepted_loans     (staging)
--   2. dim_borrower           (dimension)
--   3. dim_loan_details       (dimension)
--   4. dim_date               (dimension)
--   5. dim_rejected           (dimension)
--   6. fact_loan_performance  (fact)
--   7. fact_credit_profile    (fact)
--   8. fact_hardship          (fact)
--   9. fact_debt_settlement   (fact)
-- ============================================================


-- ============================================================
-- SECTION 1 — STAGING TABLE
-- Holds raw CSV data exactly as imported, all columns as TEXT
-- This is the source for all downstream table population
-- ============================================================

USE lending_club_db;

LOAD DATA LOCAL INFILE 'C:/Users/USER/Desktop/Projects/Credit Analytics/Credit-Risk-Analysis/Data/Raw/accepted_2007_to_2018Q4.csv'
INTO TABLE stg_accepted_loans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- SECTION 2 — DIMENSION TABLES
-- Holds transformed data for dimension tables
-- ============================================================

-- dim_borrower: Who borrowed the money
INSERT INTO dim_borrower (
    member_id, emp_title, emp_length, home_ownership,
    annual_inc, addr_state, zip_code, application_type, annual_inc_joint
)
SELECT DISTINCT
    member_id,
    emp_title,
    emp_length,
    home_ownership,
    NULLIF(annual_inc, '') + 0,
    addr_state,
    zip_code,
    application_type,
    NULLIF(annual_inc_joint, '') + 0
FROM stg_accepted_loans;
);

-- dim_loan_details: What the loan looked like at issuance
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

-- dim_date: Calendar table for time intelligence in Power BI
SET SESSION cte_max_recursion_depth = 5000;

INSERT INTO dim_date (date_id, full_date, day, month, month_name, quarter, year, day_of_week, day_name, is_weekend)
WITH RECURSIVE date_series AS (
    SELECT DATE('2007-01-01') AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM date_series
    WHERE dt < '2019-12-31'
)
SELECT
    DATE_FORMAT(dt, '%Y%m%d') AS date_id,
    dt AS full_date,
    DAY(dt) AS day,
    MONTH(dt) AS month,
    MONTHNAME(dt) AS month_name,
    QUARTER(dt) AS quarter,
    YEAR(dt) AS year,
    DAYOFWEEK(dt) AS day_of_week,
    DAYNAME(dt) AS day_name,
    CASE WHEN DAYOFWEEK(dt) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_series;

-- dim_rejected: Applications that were turned down
LOAD DATA LOCAL INFILE 'C:/Users/USER/Desktop/Projects/Credit Analytics/Credit-Risk-Analysis/Data/Raw/rejected_2007_to_2018Q4.csv'
INTO TABLE dim_rejected
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    amount_requested,
    application_date,
    loan_title,
    risk_score,
    dti_ratio,
    zip_code,
    state,
    emp_length,
    policy_code
);


-- ============================================================
-- SECTION 4 — FACT TABLES
-- Holds transformed data for fact tables
-- ============================================================

-- fact_loan_performance: How each loan performed over time
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

-- fact_credit_profile: Borrower credit bureau data at application
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

-- fact_hardship: Loans placed on hardship programmes
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

-- fact_debt_settlement: Loans settled for less than owed
INSERT INTO fact_debt_settlement (
    loan_id, debt_settlement_flag, debt_settlement_flag_date,
    settlement_status, settlement_date, settlement_amount,
    settlement_percentage, settlement_term
)
SELECT
    id,
    debt_settlement_flag,
    STR_TO_DATE(CONCAT('01-', debt_settlement_flag_date), '%d-%b-%Y'),
    settlement_status,
    STR_TO_DATE(CONCAT('01-', settlement_date), '%d-%b-%Y'),
    NULLIF(settlement_amount, '') + 0,
    NULLIF(settlement_percentage, '') + 0,
    NULLIF(settlement_term, '') + 0
FROM stg_accepted_loans
WHERE debt_settlement_flag = 'Y';

-- ============================================================
-- END OF MASTER IMPORT SCRIPT
-- ============================================================