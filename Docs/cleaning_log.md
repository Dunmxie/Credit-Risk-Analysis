# Data Cleaning Log
## Date: 10/5/2026

### Data Audit Overview
| Total Raw Records | Records Post-Cleaning |Data Retention Rate|
|-------|---------|---------------|
| 2,260,701 | 2,260,668 | 99.99% |
|

**Audit Note:** The retention of 99.99% of records ensures that the cleaning process removed "noise" (footer rows) without compromising the statistical significance of the portfolio analysis.

## Pre-Cleaning Exploration Results

| Check | Finding |
|-------|---------|
| Term values | Clean — only '36 months' and '60 months' |
| Employment length | 222,556 blank rows identified |
| NULL grades/purpose/term | 0 — all clean |
| DTI range | Min: -1.00, Max: 999.00, Avg: 18.82 |
| DTI nulls | 1,744 null rows |
| DTI extreme (>100) | 2,561 rows |
| Interest rate range | Min: 5.31%, Max: 30.99% — clean |
| Loan status distinct values | 9 values including 2 verbose policy values |

---

## Issues Found and Resolved

### 1. Blank Employment Length — dim_borrower
- **Issue:** 222,556 rows had blank emp_length values
- **Cause:** Self-employed, unemployed, or not collected at application
- **Fix:** Replaced blanks with 'Not Specified'
- **Before:** 222,556 blank rows
- **After:** 0 blank rows
- **Script:** [sql/03_cleaning/01_clean_emp_length.sql](Sql/03_Cleaning.sql/01_clean_emp_length.sql)

### 2. Invalid DTI Values — fact_credit_profile
- **Issue:** DTI values ranged from -1.00 to 999.00. This range reveals the problem of extreme outliers and system errors.
- **Impact:** Uncleaned DTI would have artificially inflated the Risk vs. DTI correlation.
- **Breakdown:**
  - Extreme (above 100): 2,561 rows
  - Invalid negative: 2 rows
  - Missing/NULL: 1,744 rows
  - Valid rows: 2,256,394 rows
- **Fix:** Implemented a Flagging System. By adding dti_flag, we preserve the record for volume analysis while excluding the extreme values from the risk calculations and I then set invalid values to NULL.
- **Clean DTI range after fix:** Min: 0.00, Max: 100.00, Avg: 18.57
- **Script:** [sql/03_cleaning/02_clean_dti.sql](Sql/03_Cleaning.sql/02_clean_dti.sql)

### 3. Verbose Loan Status Values — fact_loan_performance
- **Issue:** 2,749 rows had verbose status starting with
  'Does not meet the credit policy'
- **Additional issue:** 33 rows had completely empty loan_status
- **Fix:** Simplified verbose statuses to core values using CASE WHEN,
  added policy_exception flag column, replaced blanks with 'Unknown'
- **Script:** [sql/03_cleaning/03_clean_loan_status.sql](Sql/03_Cleaning.sql/03_clean_loan_status.sql)

#### Final Loan Status Distribution After Cleaning
| Loan Status | Count |
|-------------|-------|
| Fully Paid | 1,078,739 |
| Current | 878,317 |
| Charged Off | 269,320 |
| Late (31-120 days) | 21,467 |
| In Grace Period | 8,436 |
| Late (16-30 days) | 4,349 |
| Default | 40 |
| Unknown | 33 |

### 4. Added Analytical Flag Columns — fact_loan_performance
- **Feature Engineering:** Created is_defaulted and is_concluded flags.
- **Impact:** This removes noise from the active portfolio (Current loans) to focus purely on historical performance. This is the difference between an estimated and a realized loss analysis.
- **Script:** s[ql/03_cleaning/04_add_analytical_flags.sql](Sql/03_Cleaning.sql/04_add_analytical_flags.sql)

### 5. CSV Footer Rows Removed — All Fact Tables
- **Issue:** Identified 33 orphaned records during Foreign Key constraint application.
- **Diagnostic:** Pattern matching revealed these were Lending Club summary footers, not borrower records.
- **Fix:** Used REGEXP to purge non-numeric loan_id values. This allowed for a strict Star Schema with enforced constraints, ensuring no future orphaned data can enter the warehouse.
- **Script:** [sql/03_cleaning/05_remove_footer_rows.sql](Sql/03_Cleaning.sql/05_remove_footer_rows.sql)
- **Rows deleted:** 33
- **Impact on analysis:** Zero — these were never real loans

#### Key Business Metrics Unlocked By Flags
| Metric | Value |
|--------|-------|
| Overall default rate | 12.86% |
| Concluded loan default rate | 21.57% |

> The concluded default rate of 21.57% is the headline KPI —
> more than 1 in 5 loans that reached a final state ended in loss.

---

## Data Quality Summary After Cleaning

| Table | Issue | Rows Affected | Resolution | Business Impact|
|-------|-------|---------------|------------|----------------|
| dim_borrower | Blank emp_length | 222,556 | Replaced with 'Not Specified' | Prevents "bias of the unemployed" in risk clusters|
| fact_credit_profile | Invalid DTI | 2,563 | Set to NULL with dti_flag | Prevents 999% DTI outliers from artificially inflating the portfolio’s average risk profile |
| fact_credit_profile | NULL DTI | 1,744 | Flagged as 'Missing' | Distinguishes between borrowers with no debt and those with failed data collection |
| fact_loan_performance | Verbose status | 2,749 | Simplified with policy_exception flag | Enables clean time-series trending without string-matching overhead |
| fact_loan_performance | Empty status | 33 | Replaced with 'Unknown' | Enables clean time-series trending and high-speed filtering without high-latency string matching |
| fact_loan_performance | Added flags | All rows | is_defaulted, is_concluded added | Protects the integrity of the FICO/DTI correlation model |

## ⚠️ The Risk of Inaction
- **Skewed Underwriting:** Without nullifying the extreme DTI values, the correlation between debt and default would have been statistically diluted, leading to incorrect "safe" lending thresholds.

- **Referential Integrity Collapse:** Failing to remove the 33 CSV footer rows would have prevented the enforcement of Foreign Key Constraints, allowing ghost data to corrupt the Star Schema.

- **KPI Misreporting:** Without the is_concluded flag, the default rate would likely include Current loans, which artificially lowers the perceived risk and provides a false sense of security to stakeholders.