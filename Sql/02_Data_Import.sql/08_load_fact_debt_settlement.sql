-- =============================================================
-- Script:  08_load_fact_debt_settlement.sql
-- Purpose: Populate fact_debt_settlement table
-- =============================================================

INSERT INTO fact_debt_settlement (
    loan_id, debt_settlement_flag, debt_settlement_flag_date,
    settlement_status, settlement_date, settlement_amount,
    settlement_percentage, settlement_term
)
SELECT
    id,
    debt_settlement_flag,
    STR_TO_DATE(CONCAT('01-', debt_settlement_flag_date), '%d-%b-%Y'),
    settlement_status,
    STR_TO_DATE(CONCAT('01-', settlement_date), '%d-%b-%Y'),
    NULLIF(settlement_amount, '') + 0,
    NULLIF(settlement_percentage, '') + 0,
    NULLIF(settlement_term, '') + 0
FROM stg_accepted_loans
WHERE debt_settlement_flag = 'Y';