-- =============================================================
-- Script:  02_load_dim_rejected_loans.sql
-- Purpose: Load raw rejected loans CSV into dim_rejected table
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/05/2026
-- =============================================================

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