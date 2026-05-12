-- ============================================================
-- MASTER SCRIPT 04 — SQL ANALYSIS
-- Project:  Credit Risk Analytics
-- Author:   [Your Name]
-- Date:     [Today's Date]
--
-- Description:
--   10 analytical queries answering core business questions
--   a credit lending organisation's risk and portfolio teams
--   ask on a daily basis. All queries join across the star
--   schema and use window functions, CTEs, and aggregations
--   to produce insights ready for Power BI visualisation.
--
-- Queries:
--   00 - Add Foreign Keys
--   01 - Default Rate by Loan Grade
--   02 - Default Rate by FICO Band
--   03 - Default Rate by DTI Band
--   04 - Monthly Loan Issuance Trend
--   05 - Year Over Year Default Rate
--   06 - Default Rate by US State
--   07 - Default Rate by Loan Purpose
--   08 - Default Rate by Employment Length
--   09 - Financial Loss Analysis
--   10 - High Risk Borrower Profile
--
-- Key Results:
--   Overall default rate:        12.86%
--   Concluded default rate:      21.57%
--   Highest risk grade:          G  at 52.20%
--   Highest risk state:          MS at 29.25%
--   Highest risk purpose:        Small Business at 32.04%
--   Portfolio deterioration:     15.60% (2013) → 28.58% (2018)
-- ============================================================

USE lending_club_db;


-- ============================================================
-- QUERY 00 — FOREIGN KEY CONSTRAINTS
-- Purpose: Establish referential integrity across all tables
--          Run once after data import and cleaning
-- ============================================================

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

ALTER TABLE dim_borrower
ADD CONSTRAINT fk_borrower_loan
FOREIGN KEY (loan_id) REFERENCES dim_loan_details(loan_id);

-- Verification
-- SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME
-- FROM information_schema.KEY_COLUMN_USAGE
-- WHERE REFERENCED_TABLE_SCHEMA = 'lending_club_db'
-- ORDER BY TABLE_NAME;
--
-- Expected: 5 foreign key relationships all pointing to
-- dim_loan_details


-- ============================================================
-- QUERY 01 — DEFAULT RATE BY LOAN GRADE
-- Purpose:  Calculate default rate for each loan grade
-- Business: Which grades carry the highest risk?
-- Result:   Default rate rises from 6.61% (A) to 52.20% (G)
-- ============================================================

SELECT
    d.grade,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_concluded)                                         AS concluded_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(SUM(f.is_defaulted) * 100.0 / COUNT(*), 2)           AS overall_default_rate_pct,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
WHERE d.grade IS NOT NULL
GROUP BY d.grade
ORDER BY d.grade;

-- Results:
-- A  433,027   6.61%   7.08%   $14,603
-- B  663,557  14.61%  10.68%   $14,173
-- C  650,053  24.42%  14.14%   $15,038
-- D  324,424  32.74%  18.14%   $15,712
-- E  135,639  40.73%  21.83%   $17,453
-- F   41,800  47.13%  25.45%   $19,125
-- G   12,168  52.20%  28.07%   $20,384
--
-- Key insight: Grade G default rate exceeds 50% — more than
-- half of all concluded Grade G loans ended in loss even at
-- a 28% average interest rate


-- ============================================================
-- QUERY 02 — DEFAULT RATE BY FICO SCORE BAND
-- Purpose:  Group borrowers into FICO bands and compare
--           default rates across credit score ranges
-- Business: How does credit score predict default?
-- Result:   Default rate nearly quadruples from Exceptional
--           to Fair FICO borrowers
-- ============================================================

SELECT
    CASE
        WHEN c.fico_range_low >= 800 THEN '800+ Exceptional'
        WHEN c.fico_range_low >= 740 THEN '740-799 Very Good'
        WHEN c.fico_range_low >= 670 THEN '670-739 Good'
        WHEN c.fico_range_low >= 580 THEN '580-669 Fair'
        WHEN c.fico_range_low >= 300 THEN '300-579 Poor'
        ELSE 'Unknown'
    END                                                         AS fico_band,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(AVG(c.fico_range_low), 0)                             AS avg_fico_score,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate_pct
FROM fact_loan_performance f
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
WHERE c.fico_range_low IS NOT NULL
GROUP BY fico_band
ORDER BY avg_fico_score DESC;

-- Results:
-- 800+ Exceptional   31,048    7.42%   7.84%
-- 740-799 Very Good 251,024   11.26%   9.29%
-- 670-739 Good    1,610,768   21.56%  13.28%
-- 580-669 Fair      367,828   28.14%  15.32%
--
-- Key insight: 670-739 Good band holds 71% of all loans —
-- entire portfolio performance depends on this segment


-- ============================================================
-- QUERY 03 — DEFAULT RATE BY DTI BAND
-- Purpose:  Group borrowers into DTI bands and analyse
--           how debt burden relates to default risk
-- Business: Does high DTI predict default?
-- Result:   Default rate more than doubles from Low to
--           Extreme DTI borrowers
-- ============================================================

SELECT
    CASE
        WHEN c.dti IS NULL           THEN 'Unknown'
        WHEN c.dti < 10              THEN '0-9% Low'
        WHEN c.dti BETWEEN 10 AND 19 THEN '10-19% Moderate'
        WHEN c.dti BETWEEN 20 AND 29 THEN '20-29% High'
        WHEN c.dti BETWEEN 30 AND 39 THEN '30-39% Very High'
        WHEN c.dti >= 40             THEN '40%+ Extreme'
    END                                                         AS dti_band,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(AVG(c.dti), 2)                                        AS avg_dti,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount
FROM fact_loan_performance f
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
GROUP BY dti_band
ORDER BY avg_dti;

-- Results:
-- 0-9% Low          407,848   16.43%   6.43
-- 10-19% Moderate   831,479   19.03%  14.62
-- 20-29% High       635,145   24.46%  24.06
-- 30-39% Very High  210,893   31.08%  33.34
-- 40%+ Extreme       24,636   38.45%  53.46
-- Unknown           150,667   ~24%    NULL
--
-- Key insight: Missing DTI itself is a risk signal —
-- unknown DTI borrowers default at above-average rates


-- ============================================================
-- QUERY 04 — MONTHLY LOAN ISSUANCE TREND
-- Purpose:  Track how loan volume and value grew over time
-- Business: How did the portfolio grow 2007-2018?
-- Result:   Portfolio grew from 24 loans/month (2007) to
--           46,000+ loans/month (2018)
-- ============================================================

SELECT
    YEAR(d.issue_d)                                             AS issue_year,
    MONTH(d.issue_d)                                            AS issue_month,
    MONTHNAME(d.issue_d)                                        AS month_name,
    COUNT(*)                                                    AS loans_issued,
    ROUND(SUM(d.loan_amnt), 2)                                  AS total_loan_value,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate
FROM dim_loan_details d
JOIN fact_loan_performance f
    ON d.loan_id = f.loan_id
WHERE d.issue_d IS NOT NULL
GROUP BY
    issue_year,
    issue_month,
    month_name
ORDER BY
    issue_year,
    issue_month;

-- Results: 142 monthly rows from June 2007 to December 2018
-- Key insight: Portfolio volume grew 1,900x over 11 years
-- Average loan size grew from $3,827 (2007) to $16,000+ (2018)


-- ============================================================
-- QUERY 05 — YEAR OVER YEAR DEFAULT RATE
-- Purpose:  Track how default rate changed each year
-- Business: Is the portfolio getting riskier or safer?
-- Uses:     LAG window function for year-over-year comparison
-- Result:   Default rate nearly doubled 2013-2018
-- ============================================================

WITH yearly_stats AS (
    SELECT
        YEAR(d.issue_d)                                         AS issue_year,
        COUNT(*)                                                AS total_loans,
        SUM(f.is_defaulted)                                     AS defaulted_loans,
        SUM(f.is_concluded)                                     AS concluded_loans,
        ROUND(
            SUM(f.is_defaulted) * 100.0 /
            NULLIF(SUM(f.is_concluded), 0), 2
        )                                                       AS default_rate_pct,
        ROUND(SUM(d.loan_amnt), 2)                              AS total_loan_value
    FROM fact_loan_performance f
    JOIN dim_loan_details d
        ON f.loan_id = d.loan_id
    WHERE d.issue_d IS NOT NULL
    GROUP BY issue_year
)
SELECT
    issue_year,
    total_loans,
    concluded_loans,
    defaulted_loans,
    default_rate_pct,
    total_loan_value,
    ROUND(
        default_rate_pct - LAG(default_rate_pct)
        OVER (ORDER BY issue_year), 2
    )                                                           AS yoy_default_rate_change
FROM yearly_stats
ORDER BY issue_year;

-- Results:
-- 2007  26.20%         —
-- 2008  20.73%   -5.47
-- 2009  13.69%   -7.04  (post-crisis tightening)
-- 2010  14.01%   +0.32
-- 2011  15.18%   +1.17
-- 2012  16.20%   +1.02
-- 2013  15.60%   -0.60
-- 2014  18.60%   +3.00
-- 2015  20.55%   +1.95
-- 2016  24.84%   +4.29  (largest single year deterioration)
-- 2017  27.86%   +3.02
-- 2018  28.58%   +0.72
--
-- Key insight: 2016 inflection point — largest single year
-- jump as rapid volume growth drove underwriting pressure


-- ============================================================
-- QUERY 06 — DEFAULT RATE BY US STATE
-- Purpose:  Identify geographic risk concentrations
-- Business: Are there states with disproportionate risk?
-- Result:   Mississippi (29.25%) nearly double DC (14.40%)
--           despite similar FICO scores and DTI ratios
-- ============================================================

SELECT
    b.addr_state                                                AS state,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(c.fico_range_low), 0)                             AS avg_fico_score,
    ROUND(AVG(c.dti), 2)                                        AS avg_dti
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
JOIN dim_borrower b
    ON f.loan_id = b.loan_id
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
WHERE b.addr_state IS NOT NULL
  AND b.addr_state != ''
GROUP BY b.addr_state
HAVING COUNT(*) > 1000
ORDER BY concluded_default_rate_pct DESC;

-- Results: 51 states
-- Top 5 highest: MS 29.25%, NE 27.76%, AR 25.86%,
--               AL 25.44%, OK 25.24%
-- Bottom 5 lowest: DC 14.40%, VT 15.22%, ME 15.52%,
--                 OR 15.59%, CO 16.71%
--
-- Key insight: Geography is an independent risk factor —
-- similar FICO and DTI across states but very different
-- default rates driven by local economic conditions


-- ============================================================
-- QUERY 07 — DEFAULT RATE BY LOAN PURPOSE
-- Purpose:  Analyse which loan purposes carry most risk
-- Business: What are borrowers using loans for and which
--           purposes end in default most often?
-- Result:   Small business (32.04%) vs wedding (12.43%)
-- ============================================================

SELECT
    d.purpose,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(d.int_rate), 2)                                   AS avg_interest_rate,
    ROUND(SUM(d.loan_amnt), 2)                                  AS total_portfolio_value
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
WHERE d.purpose IS NOT NULL
  AND d.purpose != ''
GROUP BY d.purpose
ORDER BY concluded_default_rate_pct DESC;

-- Results:
-- small_business    32.04%   $405M
-- moving            25.27%   $129M
-- renewable_energy  25.21%    $15M
-- house             24.47%   $221M
-- medical           23.73%   $260M
-- debt_consolidation 22.75% $20.4B  (largest segment)
-- credit_card       18.29%   $7.9B
-- car               16.03%   $225M
-- wedding           12.43%    $24M  (lowest risk)
--
-- Key insight: Debt consolidation dominates the portfolio
-- at $20.4B but has a below-average default rate —
-- these borrowers are motivated to improve their finances


-- ============================================================
-- QUERY 08 — DEFAULT RATE BY EMPLOYMENT LENGTH
-- Purpose:  Analyse how job stability relates to default risk
-- Business: Do longer-employed borrowers default less?
-- Result:   Not Specified (29.28%) vs 10+ years (20.28%)
-- ============================================================

SELECT
    b.emp_length,
    COUNT(*)                                                    AS total_loans,
    SUM(f.is_defaulted)                                         AS defaulted_loans,
    ROUND(
        SUM(f.is_defaulted) * 100.0 /
        NULLIF(SUM(f.is_concluded), 0), 2
    )                                                           AS concluded_default_rate_pct,
    ROUND(AVG(d.loan_amnt), 2)                                  AS avg_loan_amount,
    ROUND(AVG(c.dti), 2)                                        AS avg_dti,
    ROUND(AVG(c.fico_range_low), 0)                             AS avg_fico_score
FROM fact_loan_performance f
JOIN dim_loan_details d
    ON f.loan_id = d.loan_id
JOIN dim_borrower b
    ON f.loan_id = b.loan_id
JOIN fact_credit_profile c
    ON f.loan_id = c.loan_id
GROUP BY b.emp_length
ORDER BY concluded_default_rate_pct DESC;

-- Results:
-- Not Specified  29.28%  (missing data = risk signal)
-- < 1 year       22.41%
-- 1 year         22.21%
-- 3 years        21.65%
-- 4 years        21.51%
-- 2 years        21.43%
-- 8 years        21.20%
-- 5 years        21.18%
-- 9 years        21.16%
-- 6 years        20.84%
-- 7 years        20.80%
-- 10+ years      20.28%
--
-- Key insight: Employment length is a weak predictor —
-- only 2pp difference between < 1 year and 10+ years.
-- FICO and DTI are doing most of the predictive work.
-- However missing employment data is a strong signal.


-- ============================================================
-- QUERY 09 — FINANCIAL LOSS ANALYSIS
-- Purpose:  Quantify the actual financial impact of defaults
-- Business: How much money has been lost to defaults?
--           Which grade/purpose/year combinations lost most?
-- Uses:     CTE with conditional aggregation
-- ============================================================

WITH loss_summary AS (
    SELECT
        d.grade,
        d.purpose,
        YEAR(d.issue_d)                                         AS issue_year,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN d.funded_amnt ELSE 0 END)                      AS total_funded_to_defaulters,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN f.total_rec_prncp ELSE 0 END)                  AS total_recovered,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN d.funded_amnt - f.total_rec_prncp ELSE 0 END)  AS net_loss,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN f.total_rec_late_fee ELSE 0 END)               AS late_fees_collected,
        SUM(CASE WHEN f.is_defaulted = 1
            THEN f.recoveries ELSE 0 END)                       AS collection_recoveries,
        COUNT(CASE WHEN f.is_defaulted = 1
            THEN 1 END)                                         AS defaulted_loan_count
    FROM fact_loan_performance f
    JOIN dim_loan_details d
        ON f.loan_id = d.loan_id
    GROUP BY
        d.grade,
        d.purpose,
        issue_year
)
SELECT
    grade,
    purpose,
    issue_year,
    defaulted_loan_count,
    ROUND(total_funded_to_defaulters, 2)                        AS total_funded_to_defaulters,
    ROUND(total_recovered, 2)                                   AS total_recovered,
    ROUND(net_loss, 2)                                          AS net_loss,
    ROUND(late_fees_collected, 2)                               AS late_fees_collected,
    ROUND(collection_recoveries, 2)                             AS collection_recoveries,
    ROUND(
        net_loss * 100.0 /
        NULLIF(total_funded_to_defaulters, 0), 2
    )                                                           AS loss_rate_pct
FROM loss_summary
WHERE defaulted_loan_count > 0
ORDER BY net_loss DESC;

-- Top loss segments are Grade C and D debt consolidation
-- loans from 2015 and 2016 — the period when both volume
-- and default rates were rising simultaneously


-- ============================================================
-- QUERY 10 — HIGH RISK BORROWER PROFILE
-- Purpose:  Compare profile of defaulted vs fully paid
--           borrowers side by side
-- Business: What separates a good borrower from a bad one?
-- Uses:     Two CTEs and multiple table joins
-- Result:   Defaulters are subtly but consistently worse
--           across every metric
-- ============================================================

WITH borrower_segments AS (
    SELECT
        f.loan_id,
        f.loan_status,
        f.is_defaulted,
        d.grade,
        d.int_rate,
        d.loan_amnt,
        d.purpose,
        d.term,
        b.emp_length,
        b.home_ownership,
        b.annual_inc,
        c.fico_range_low,
        c.dti,
        c.delinq_2yrs,
        c.pub_rec,
        c.revol_util,
        c.open_acc,
        c.mort_acc
    FROM fact_loan_performance f
    JOIN dim_loan_details d     ON f.loan_id = d.loan_id
    JOIN dim_borrower b         ON f.loan_id = b.loan_id
    JOIN fact_credit_profile c  ON f.loan_id = c.loan_id
    WHERE f.is_concluded = 1
),
profile_comparison AS (
    SELECT
        CASE
            WHEN is_defaulted = 1 THEN 'Defaulted'
            ELSE 'Fully Paid'
        END                                                     AS borrower_segment,
        COUNT(*)                                                AS total_borrowers,
        ROUND(AVG(fico_range_low), 0)                           AS avg_fico_score,
        ROUND(AVG(dti), 2)                                      AS avg_dti,
        ROUND(AVG(annual_inc), 2)                               AS avg_annual_income,
        ROUND(AVG(loan_amnt), 2)                                AS avg_loan_amount,
        ROUND(AVG(int_rate), 2)                                 AS avg_interest_rate,
        ROUND(AVG(revol_util), 2)                               AS avg_revolving_utilisation,
        ROUND(AVG(delinq_2yrs), 2)                              AS avg_delinquencies_2yrs,
        ROUND(AVG(pub_rec), 2)                                  AS avg_public_records,
        ROUND(AVG(open_acc), 2)                                 AS avg_open_accounts,
        ROUND(AVG(mort_acc), 2)                                 AS avg_mortgage_accounts
    FROM borrower_segments
    GROUP BY borrower_segment
)
SELECT *
FROM profile_comparison
ORDER BY borrower_segment DESC;

-- Results:
-- Fully Paid  1,078,739  FICO:698  DTI:17.71  Income:$77,696
--                        Loan:$14,125  Rate:12.63%  Util:51.08%
--
-- Defaulted     269,360  FICO:688  DTI:20.03  Income:$70,399
--                        Loan:$15,548  Rate:15.71%  Util:54.76%
--
-- Key insight: Defaulters are not dramatically different.
-- 10pt lower FICO, 9% lower income, 3pp higher interest.
-- Credit risk is subtle — this is why lenders use complex
-- models to find patterns simple metrics miss.


-- ============================================================
-- END OF MASTER ANALYSIS SCRIPT
-- All 10 queries complete.
-- Results documented in docs/analysis_insights.md
-- Dashboard built in powerbi/credit_risk_dashboard.pbix
-- ============================================================