-- =============================================================
-- Script:  04_fact_loan_performance.sql
-- Purpose: Holds how the loan is performing
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/5/2026
-- =============================================================

CREATE TABLE fact_loan_performance (
    loan_id               VARCHAR(50) PRIMARY KEY,
    borrower_id           INT,
    loan_status           VARCHAR(100),
    out_prncp             DECIMAL(15,2),
    out_prncp_inv         DECIMAL(15,2),
    total_pymnt           DECIMAL(15,2),
    total_pymnt_inv       DECIMAL(15,2),
    total_rec_prncp       DECIMAL(15,2),
    total_rec_int         DECIMAL(15,2),
    total_rec_late_fee    DECIMAL(10,2),
    recoveries            DECIMAL(15,2),
    collection_recovery_fee DECIMAL(10,2),
    last_pymnt_d          DATE,
    last_pymnt_amnt       DECIMAL(15,2),
    next_pymnt_d          DATE,
    last_credit_pull_d    DATE,
    pymnt_plan            VARCHAR(5)
);