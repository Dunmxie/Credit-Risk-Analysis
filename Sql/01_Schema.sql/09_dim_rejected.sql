-- =============================================================
-- Script:  09_dim_rejected.sql
-- Purpose: Holds all rejected loan applications
-- =============================================================


CREATE TABLE dim_rejected (
    rejected_id       INT PRIMARY KEY AUTO_INCREMENT,
    amount_requested  DECIMAL(15,2),
    application_date  DATE,
    loan_title        VARCHAR(200),
    risk_score        DECIMAL(10,2),
    dti_ratio         DECIMAL(10,2),
    zip_code          VARCHAR(10),
    state             VARCHAR(5),
    emp_length        VARCHAR(20),
    policy_code       VARCHAR(20)
);
