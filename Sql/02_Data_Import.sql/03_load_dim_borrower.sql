-- =============================================================
-- Script:  03_load_dim_borrower.sql
-- Purpose: Populate dim_borrower table.
-- =============================================================

INSERT INTO dim_borrower (
    loan_id, 
    emp_title, 
    emp_length, 
    home_ownership,
    annual_inc, 
    addr_state, 
    zip_code, 
    application_type, 
    annual_inc_joint
)
SELECT 
    id, -- Mapping 'id' from staging to 'loan_id'
    emp_title,
    CASE 
        WHEN emp_length IS NULL OR emp_length = '' THEN 'Not Specified'
        ELSE emp_length 
    END,
    home_ownership,
    NULLIF(annual_inc, '') + 0,
    addr_state,
    zip_code,
    application_type,
    NULLIF(annual_inc_joint, '') + 0
FROM stg_accepted_loans
WHERE id IS NOT NULL 
  AND id != ''
  AND id REGEXP '^[0-9]+$';