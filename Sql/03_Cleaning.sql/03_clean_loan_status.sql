-- ============================================================
-- Script:  03_clean_loan_status.sql
-- Purpose: Simplify verbose loan status values
--          and add policy_exception flag column
-- Table:   fact_loan_performance
-- ============================================================

-- Step 1: Add a policy exception flag column
ALTER TABLE fact_loan_performance
ADD COLUMN policy_exception TINYINT(1) DEFAULT 0;

-- Step 2: Flag the policy exception rows
UPDATE fact_loan_performance
SET policy_exception = 1
WHERE loan_status LIKE 'Does not meet the credit policy%';

-- Step 3: Simplify the verbose status values
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

-- Step 4: Verify all statuses are now clean
SELECT DISTINCT loan_status, COUNT(*) as count
FROM fact_loan_performance
GROUP BY loan_status
ORDER BY count DESC;