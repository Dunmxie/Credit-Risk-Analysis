-- ============================================================
-- Script:  01_clean_emp_length.sql
-- Purpose: Replace blank employment length with 'Not Specified'
-- Table:   dim_borrower
-- Rows affected: ~222,556
-- ============================================================

USE lending_club_db;

-- Before: check current blank count
SELECT 
    COUNT(*) AS blank_emp_length
FROM dim_borrower
WHERE emp_length IS NULL OR emp_length = '';

SET SQL_SAFE_UPDATES = 0;

-- Apply fix
UPDATE dim_borrower
SET emp_length = 'Not Specified'
WHERE emp_length IS NULL OR emp_length = '';

-- After: verify no blanks remain
SELECT 
    COUNT(*) AS blank_emp_length_after_clean
FROM dim_borrower
WHERE emp_length IS NULL OR emp_length = '';