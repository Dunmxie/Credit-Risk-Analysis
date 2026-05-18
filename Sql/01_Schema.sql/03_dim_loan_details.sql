-- =============================================================
-- Script:  03_dim_loan_details.sql
-- Purpose: Holds the static details of the loan such as amount, term, interest rate, etc.
-- =============================================================

CREATE TABLE dim_loan_details (
    loan_id           VARCHAR(50) PRIMARY KEY,
    loan_amnt         DECIMAL(15,2),
    funded_amnt       DECIMAL(15,2),
    funded_amnt_inv   DECIMAL(15,2),
    term              VARCHAR(20),
    int_rate          DECIMAL(6,3),
    installment       DECIMAL(10,2),
    grade             VARCHAR(5),
    sub_grade         VARCHAR(5),
    purpose           VARCHAR(50),
    title             VARCHAR(200),
    issue_d           DATE,
    initial_list_status VARCHAR(5),
    disbursement_method VARCHAR(20),
    policy_code       VARCHAR(10)
);
