# Data Cleaning Log

## Date: 10/5/2026

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
- **Script:** sql/03_cleaning/01_clean_emp_length.sql

### 2. Invalid DTI Values — fact_credit_profile
- **Issue:** DTI values ranged from -1.00 to 999.00
- **Breakdown:**
  - Extreme (above 100): 2,561 rows
  - Invalid negative: 2 rows
  - Missing/NULL: 1,744 rows
  - Valid rows: 2,256,394 rows
- **Fix:** Set invalid values to NULL, added dti_flag column
- **Clean DTI range after fix:** Min: 0.00, Max: 100.00, Avg: 18.57
- **Script:** sql/03_cleaning/02_clean_dti.sql

### 3. Verbose Loan Status Values — fact_loan_performance
- **Issue:** 2,749 rows had verbose status starting with
  'Does not meet the credit policy'
- **Additional issue:** 33 rows had completely empty loan_status
- **Fix:** Simplified verbose statuses to core values using CASE WHEN,
  added policy_exception flag column, replaced blanks with 'Unknown'
- **Script:** sql/03_cleaning/03_clean_loan_status.sql

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
- **Added:** is_defaulted — 1 if Charged Off, Default, or Late 31-120 days
- **Added:** is_concluded — 1 if Fully Paid, Charged Off, or Default
- **Script:** sql/03_cleaning/04_add_analytical_flags.sql

### 5. CSV Footer Rows Removed — All Fact Tables
- **Issue:** 33 Lending Club CSV summary/footer rows loaded 
  into fact tables with text descriptions as loan_id values
  e.g. "Total amount funded in policy code 1: 6417608175"
- **Cause:** Lending Club appended summary rows at the bottom
  of the raw CSV — they are not real loan records
- **Detected:** When adding foreign key constraints — MySQL 
  Error 1452 flagged orphaned loan_ids
- **Fix:** Deleted rows where loan_id fails REGEXP '^[0-9]+$'
- **Script:** sql/03_cleaning/05_remove_footer_rows.sql
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

| Table | Issue | Rows Affected | Resolution |
|-------|-------|---------------|------------|
| dim_borrower | Blank emp_length | 222,556 | Replaced with 'Not Specified' |
| fact_credit_profile | Invalid DTI | 2,563 | Set to NULL with dti_flag |
| fact_credit_profile | NULL DTI | 1,744 | Flagged as 'Missing' |
| fact_loan_performance | Verbose status | 2,749 | Simplified with policy_exception flag |
| fact_loan_performance | Empty status | 33 | Replaced with 'Unknown' |
| fact_loan_performance | Added flags | All rows | is_defaulted, is_concluded added |
|