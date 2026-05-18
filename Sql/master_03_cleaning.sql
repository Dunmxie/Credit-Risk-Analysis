-- ============================================================
-- MASTER SCRIPT 03 — DATA CLEANING
-- Project:  Credit Risk Analytics
--
-- Cleaning Summary:
--   - 222,556 blank emp_length values → 'Not Specified'
--   - 2,563 invalid DTI values → NULL with dti_flag
--   - 2,749 verbose loan statuses → simplified with flag
--   - 33 empty loan statuses → 'Unknown'
--   - Added is_defaulted and is_concluded flag columns
--
-- Key Business Metrics Unlocked:
--   - Overall default rate:   12.86%
--   - Concluded default rate: 21.57%
-- ============================================================

USE lending_club_db;

-- ============================================================
-- SECTION 1 — CLEAN EMPLOYMENT LENGTH
-- Table:  dim_borrower
-- Issue:  222,556 rows with blank emp_length
-- Fix:    Replace blanks with 'Not Specified'
-- ============================================================

-- Before count (for reference)
-- blank_emp_length: 222,556

UPDATE dim_borrower
SET emp_length = 'Not Specified'
WHERE emp_length IS NULL OR emp_length = '';

-- After count verification
-- SELECT COUNT(*) FROM dim_borrower
-- WHERE emp_length IS NULL OR emp_length = '';
-- Expected result: 0


-- ============================================================
-- SECTION 2 — CLEAN DTI OUTLIERS
-- Table:  fact_credit_profile
-- Issue:  DTI ranged from -1.00 to 999.00
--         2,561 rows above 100, 2 negative, 1,744 NULL
-- Fix:    Add dti_flag column, nullify invalid values
-- ============================================================

ALTER TABLE fact_credit_profile
ADD COLUMN dti_flag VARCHAR(30) DEFAULT NULL;

UPDATE fact_credit_profile
SET 
    dti_flag = CASE 
        WHEN dti > 100 THEN 'Extreme - Above 100'
        WHEN dti < 0   THEN 'Invalid - Negative'
        WHEN dti IS NULL THEN 'Missing'
        ELSE NULL 
    END,
    dti = CASE 
        WHEN dti > 100 OR dti < 0 THEN NULL 
        ELSE dti 
    END;

-- Verification
-- SELECT dti_flag, COUNT(*) AS row_count
-- FROM fact_credit_profile
-- GROUP BY dti_flag ORDER BY row_count DESC;
--
-- Expected results:
-- NULL (valid rows):       2,256,394
-- Extreme - Above 100:         2,561
-- Missing:                     1,744
-- Invalid - Negative:              2
--
-- SELECT MIN(dti), MAX(dti), ROUND(AVG(dti),2)
-- FROM fact_credit_profile WHERE dti IS NOT NULL;
-- Expected: 0.00 | 100.00 | 18.57


-- ============================================================
-- SECTION 3 — CLEAN LOAN STATUS VALUES
-- Table:  fact_loan_performance
-- Issue:  2,749 verbose policy status rows
--         33 completely empty status rows
-- Fix:    Add policy_exception flag, simplify using CASE WHEN,
--         replace empty values with 'Unknown'
-- ============================================================

ALTER TABLE fact_loan_performance
ADD COLUMN policy_exception TINYINT(1) DEFAULT 0;

UPDATE fact_loan_performance
SET policy_exception = 1
WHERE loan_status LIKE 'Does not meet the credit policy%';

UPDATE fact_loan_performance
SET loan_status = CASE
    WHEN loan_status = 'Does not meet the credit policy. Status:Fully Paid'
        THEN 'Fully Paid'
    WHEN loan_status = 'Does not meet the credit policy. Status:Charged Off'
        THEN 'Charged Off'
    WHEN loan_status = '' OR loan_status IS NULL
        THEN 'Unknown'
    ELSE loan_status
END;

-- Verification
-- SELECT DISTINCT loan_status, COUNT(*) AS count
-- FROM fact_loan_performance
-- GROUP BY loan_status ORDER BY count DESC;
--
-- Expected results:
-- Fully Paid          1,078,739
-- Current               878,317
-- Charged Off           269,320
-- Late (31-120 days)     21,467
-- In Grace Period         8,436
-- Late (16-30 days)       4,349
-- Default                    40
-- Unknown                    33


-- ============================================================
-- SECTION 4 — ADD ANALYTICAL FLAG COLUMNS
-- Table:  fact_loan_performance
-- Purpose: Enable fast, accurate default rate calculations
--          without complex CASE WHEN logic in every query
--
-- is_defaulted:
--   1 = Charged Off, Default, or Late (31-120 days)
--   0 = all other statuses
--
-- is_concluded:
--   1 = loan has reached a final state (Fully Paid, Charged Off, Default)
--   0 = loan is still active (Current, Late, In Grace Period)
-- ============================================================

ALTER TABLE fact_loan_performance
ADD COLUMN is_defaulted TINYINT(1) DEFAULT 0,
ADD COLUMN is_concluded TINYINT(1) DEFAULT 0;

SET SQL_SAFE_UPDATES = 0;

UPDATE fact_loan_performance
SET
    is_defaulted = CASE
        WHEN loan_status IN (
            'Charged Off',
            'Default',
            'Late (31-120 days)'
        ) THEN 1
        ELSE 0
    END,
    is_concluded = CASE
        WHEN loan_status IN (
            'Fully Paid',
            'Charged Off',
            'Default'
        ) THEN 1
        ELSE 0
    END;

-- Verification
-- SELECT
--     is_defaulted,
--     is_concluded,
--     COUNT(*) AS loan_count
-- FROM fact_loan_performance
-- GROUP BY is_defaulted, is_concluded
-- ORDER BY is_defaulted, is_concluded;
--
-- SELECT
--     ROUND(SUM(is_defaulted) * 100.0 / COUNT(*), 2)
--         AS overall_default_rate_pct,
--     ROUND(SUM(is_defaulted) * 100.0 / NULLIF(SUM(is_concluded),0), 2)
--         AS concluded_default_rate_pct
-- FROM fact_loan_performance;
--
-- Expected results:
-- Overall default rate:   12.86%
-- Concluded default rate: 21.57%

-- ============================================================
-- SECTION 5 — REMOVE CSV FOOTER ROWS
-- Tables: All fact tables
-- Issue:  33 Lending Club CSV summary rows loaded as data
--         with text descriptions in the loan_id column
-- Fix:    Delete all rows where loan_id is not a valid number
-- ============================================================

START TRANSACTION;

DELETE FROM fact_loan_performance 
WHERE (loan_status = 'Unknown' AND loan_id NOT REGEXP '^[0-9]+$')
   OR loan_id NOT REGEXP '^[0-9]+$';

DELETE FROM fact_credit_profile    WHERE loan_id NOT REGEXP '^[0-9]+$';
DELETE FROM fact_hardship          WHERE loan_id NOT REGEXP '^[0-9]+$';
DELETE FROM fact_debt_settlement   WHERE loan_id NOT REGEXP '^[0-9]+$';

COMMIT;

-- Verification
-- SELECT COUNT(*) AS orphaned_rows_remaining
-- FROM fact_loan_performance f
-- LEFT JOIN dim_loan_details d ON f.loan_id = d.loan_id
-- WHERE d.loan_id IS NULL
--   AND f.loan_id IS NOT NULL
--   AND f.loan_id != '';
-- Expected result: 0


-- ============================================================
-- END OF MASTER CLEANING SCRIPT
-- ============================================================
