-- ============================================================
-- Script:  05_remove_footer_rows.sql
-- Purpose: Remove CSV footer rows that loaded into fact tables
--          with text descriptions as loan_id values
-- Rows removed: 33
-- ============================================================

USE lending_club_db;

START TRANSACTION;

DELETE FROM fact_loan_performance 
WHERE (loan_status = 'Unknown' AND loan_id NOT REGEXP '^[0-9]+$')
   OR loan_id NOT REGEXP '^[0-9]+$';

DELETE FROM fact_credit_profile    WHERE loan_id NOT REGEXP '^[0-9]+$';
DELETE FROM fact_hardship          WHERE loan_id NOT REGEXP '^[0-9]+$';
DELETE FROM fact_debt_settlement   WHERE loan_id NOT REGEXP '^[0-9]+$';

COMMIT;

SELECT 
    COUNT(*) AS orphaned_rows_remaining
FROM fact_loan_performance f
LEFT JOIN dim_loan_details d 
    ON f.loan_id = d.loan_id
WHERE d.loan_id IS NULL
  AND f.loan_id IS NOT NULL
  AND f.loan_id != '';