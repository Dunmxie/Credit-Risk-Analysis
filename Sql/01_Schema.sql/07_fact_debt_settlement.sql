-- =============================================================
-- Script:  07_fact_debt_settlement.sql
-- Purpose: Holds data for loans that were settled for less than the full amount owed.
-- Author:  Oluwadunmininu Deborah Oluremi
-- Date:    10/5/2026
-- =============================================================

CREATE TABLE fact_debt_settlement (
    loan_id                 VARCHAR(50) PRIMARY KEY,
    debt_settlement_flag    VARCHAR(5),
    debt_settlement_flag_date DATE,
    settlement_status       VARCHAR(50),
    settlement_date         DATE,
    settlement_amount       DECIMAL(15,2),
    settlement_percentage   DECIMAL(6,2),
    settlement_term         INT
);