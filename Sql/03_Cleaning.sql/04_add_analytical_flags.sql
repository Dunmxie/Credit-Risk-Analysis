-- ============================================================
-- Script:  04_add_analytical_flags.sql
-- Purpose: Add is_defaulted and is_concluded flag columns
--          to make dashboard calculations simple and fast
-- Table:   fact_loan_performance
-- ============================================================

ALTER TABLE fact_loan_performance
ADD COLUMN is_defaulted TINYINT(1) DEFAULT 0,
ADD COLUMN is_concluded TINYINT(1) DEFAULT 0;

UPDATE fact_loan_performance
SET
    is_defaulted = CASE
        WHEN loan_status IN (
            'Charged Off',
            'Default',
            'Late (31-120 days)'
        ) THEN 1
        ELSE 0
    END,
    is_concluded = CASE
        WHEN loan_status IN (
            'Fully Paid',
            'Charged Off',
            'Default'
        ) THEN 1
        ELSE 0
    END;
    
SELECT 
    is_defaulted,
    is_concluded,
    COUNT(*) AS loan_count
FROM fact_loan_performance
GROUP BY is_defaulted, is_concluded
ORDER BY is_defaulted, is_concluded;

SELECT
    ROUND(SUM(is_defaulted) * 100.0 / COUNT(*), 2) 
        AS overall_default_rate_pct,
    ROUND(SUM(is_defaulted) * 100.0 / NULLIF(SUM(is_concluded), 0), 2) 
        AS concluded_default_rate_pct
FROM fact_loan_performance;