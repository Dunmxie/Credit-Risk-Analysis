-- =============================================================
-- Script:  02_dim_borrower.sql
-- Purpose: Holds information about the person who took the loan.
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/5/2026
-- =============================================================

CREATE TABLE dim_borrower (
    loan_id          VARCHAR(50) PRIMARY KEY,
    emp_title        VARCHAR(100),
    emp_length       VARCHAR(20),
    home_ownership   VARCHAR(20),
    annual_inc       DECIMAL(15,2),
    addr_state       VARCHAR(5),
    zip_code         VARCHAR(10),
    application_type VARCHAR(20),
    annual_inc_joint DECIMAL(15,2)
);