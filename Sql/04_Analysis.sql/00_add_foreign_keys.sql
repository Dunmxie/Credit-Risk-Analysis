-- ============================================================
-- Script:  00_add_foreign_keys.sql
-- Purpose: Link fact tables to dimension tables
-- ============================================================

USE lending_club_db;

ALTER TABLE fact_loan_performance
ADD CONSTRAINT fk_performance_loan
FOREIGN KEY (loan_id) REFERENCES dim_loan_details(loan_id);

ALTER TABLE fact_credit_profile
ADD CONSTRAINT fk_credit_loan
FOREIGN KEY (loan_id) REFERENCES dim_loan_details(loan_id);

ALTER TABLE fact_hardship
ADD CONSTRAINT fk_hardship_loan
FOREIGN KEY (loan_id) REFERENCES dim_loan_details(loan_id);

ALTER TABLE fact_debt_settlement
ADD CONSTRAINT fk_settlement_loan
FOREIGN KEY (loan_id) REFERENCES dim_loan_details(loan_id);

-- Verify all foreign keys exist
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'lending_club_db'
ORDER BY TABLE_NAME;