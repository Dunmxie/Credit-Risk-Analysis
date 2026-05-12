-- ============================================================
-- Script:  02_clean_dti.sql
-- Purpose: Nullify impossible and extreme DTI values
--          and add a dti_flag column to mark outliers
-- Table:   fact_credit_profile
-- ============================================================

USE lending_club_db;

-- Step 1: Add a flag column to mark rows we are nullifying
ALTER TABLE fact_credit_profile
ADD COLUMN dti_flag VARCHAR(30) DEFAULT NULL;

-- Step 2: Flag and nullify problematic rows
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

-- Step 3: Verify results
SELECT 
    dti_flag,
    COUNT(*) AS row_count
FROM fact_credit_profile
GROUP BY dti_flag
ORDER BY row_count DESC;

-- Step 4: Confirm new DTI range is clean
SELECT 
    MIN(dti) AS min_dti,
    MAX(dti) AS max_dti,
    ROUND(AVG(dti), 2) AS avg_dti
FROM fact_credit_profile
WHERE dti IS NOT NULL;