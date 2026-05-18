-- =============================================================
-- Script:  06_fact_hardship.sql
-- Purpose: Holds data for loans that went into a hardship programme
-- =============================================================

CREATE TABLE fact_hardship (
    loan_id                                  VARCHAR(50) PRIMARY KEY,
    hardship_flag                            VARCHAR(5),
    hardship_type                            VARCHAR(100),
    hardship_reason                          VARCHAR(100),
    hardship_status                          VARCHAR(50),
    deferral_term                            INT,
    hardship_amount                          DECIMAL(15,2),
    hardship_start_date                      DATE,
    hardship_end_date                        DATE,
    hardship_length                          INT,
    hardship_dpd                             INT,
    hardship_loan_status                     VARCHAR(50),
    orig_projected_additional_accrued_interest DECIMAL(15,2),
    hardship_payoff_balance_amount           DECIMAL(15,2),
    hardship_last_payment_amount             DECIMAL(15,2),
    payment_plan_start_date                  DATE
);
