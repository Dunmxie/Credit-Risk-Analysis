# Database Schema Reference
## Project: Credit Risk Analytics
## Database: lending_club_db
## Last Updated: [Today's Date]

---

## Schema Overview

Star schema design with 4 fact tables and 4 dimension tables.
All fact tables link to dim_loan_details via loan_id.
dim_borrower links to dim_loan_details via loan_id.

---

## Table Relationships

















---

## Dimension Tables

### dim_loan_details
Primary key and central hub of the star schema.
All fact tables reference this table via loan_id.

| Column | Type | Description |
|--------|------|-------------|
| loan_id | varchar(50) | PRIMARY KEY — Lending Club loan identifier |
| loan_amnt | decimal(15,2) | Amount requested by borrower |
| funded_amnt | decimal(15,2) | Amount actually funded |
| funded_amnt_inv | decimal(15,2) | Amount funded by investors |
| term | varchar(20) | Loan term — 36 months or 60 months |
| int_rate | decimal(6,3) | Interest rate charged |
| installment | decimal(10,2) | Monthly payment amount |
| grade | varchar(5) | Risk grade A through G |
| sub_grade | varchar(5) | Granular grade A1 through G5 |
| purpose | varchar(50) | Stated purpose of the loan |
| title | varchar(200) | Borrower description of purpose |
| issue_d | date | Date loan was issued |
| initial_list_status | varchar(5) | Whole or fractional listing |
| disbursement_method | varchar(20) | Cash or direct pay |
| policy_code | varchar(10) | Lending policy version |

---

### dim_borrower
Borrower identity and demographic information.
Links to dim_loan_details via loan_id.
Note: One row per loan (not per borrower) because member_id
was unavailable in source data for deduplication.

| Column | Type | Description |
|--------|------|-------------|
| borrower_id | int | PRIMARY KEY — auto increment |
| loan_id | varchar(50) | FOREIGN KEY → dim_loan_details |
| emp_title | varchar(100) | Job title |
| emp_length | varchar(20) | Employment duration |
| home_ownership | varchar(20) | Own, rent, or mortgage |
| annual_inc | decimal(15,2) | Annual income |
| addr_state | varchar(5) | US state |
| zip_code | varchar(10) | Zip code (partially masked) |
| application_type | varchar(20) | Individual or joint |
| annual_inc_joint | decimal(15,2) | Combined income for joint apps |

**Cleaning note:** 222,556 blank emp_length values
replaced with 'Not Specified'

---

### dim_date
Calendar table for Power BI time intelligence.
Covers 2007-01-01 to 2019-12-31 (4,748 rows).

| Column | Type | Description |
|--------|------|-------------|
| date_id | int | PRIMARY KEY — format YYYYMMDD |
| full_date | date | Calendar date |
| day | int | Day of month |
| month | int | Month number |
| month_name | varchar(20) | Month name |
| quarter | int | Quarter 1 through 4 |
| year | int | Year |
| day_of_week | int | Day number 1-7 |
| day_name | varchar(20) | Day name |
| is_weekend | tinyint(1) | 1 if Saturday or Sunday |

---

### dim_rejected
Rejected loan applications. Standalone table —
not linked to accepted loan tables.

| Column | Type | Description |
|--------|------|-------------|
| rejected_id | int | PRIMARY KEY — auto increment |
| amount_requested | decimal(15,2) | Amount applicant wanted |
| application_date | date | Date of application |
| loan_title | varchar(200) | Purpose of loan |
| risk_score | decimal(10,2) | Internal risk score |
| dti_ratio | decimal(10,2) | Debt-to-income ratio |
| zip_code | varchar(10) | Applicant zip code |
| state | varchar(5) | Applicant state |
| emp_length | varchar(20) | Employment duration |
| policy_code | varchar(20) | Lending policy version |

---

## Fact Tables

### fact_loan_performance
Core performance tracking table. One row per loan.
Most important table for default rate analysis.

| Column | Type | Description |
|--------|------|-------------|
| performance_id | int | PRIMARY KEY — auto increment |
| loan_id | varchar(50) | FOREIGN KEY → dim_loan_details |
| loan_status | varchar(100) | Current loan status |
| out_prncp | decimal(15,2) | Outstanding principal |
| out_prncp_inv | decimal(15,2) | Outstanding principal (investors) |
| total_pymnt | decimal(15,2) | Total amount paid to date |
| total_pymnt_inv | decimal(15,2) | Total paid to investors |
| total_rec_prncp | decimal(15,2) | Principal recovered |
| total_rec_int | decimal(15,2) | Interest recovered |
| total_rec_late_fee | decimal(10,2) | Late fees collected |
| recoveries | decimal(15,2) | Post-default recoveries |
| collection_recovery_fee | decimal(10,2) | Collection agency fees |
| last_pymnt_d | date | Date of last payment |
| last_pymnt_amnt | decimal(15,2) | Amount of last payment |
| next_pymnt_d | date | Scheduled next payment |
| last_credit_pull_d | date | Last credit check date |
| pymnt_plan | varchar(5) | Special payment plan flag |
| policy_exception | tinyint(1) | 1 = old policy loan |
| is_defaulted | tinyint(1) | 1 = defaulted loan |
| is_concluded | tinyint(1) | 1 = loan reached final state |

**Cleaning notes:**
- 2,749 verbose policy status values simplified
- 33 empty statuses set to 'Unknown'
- 33 CSV footer rows deleted
- is_defaulted and is_concluded flags added

**Key metrics:**
- Overall default rate: 12.86%
- Concluded default rate: 21.57%

---

### fact_credit_profile
Credit bureau snapshot at time of application.
One row per loan.

| Column | Type | Description |
|--------|------|-------------|
| credit_profile_id | int | PRIMARY KEY — auto increment |
| loan_id | varchar(50) | FOREIGN KEY → dim_loan_details |
| fico_range_low | int | FICO score lower bound |
| fico_range_high | int | FICO score upper bound |
| last_fico_range_low | int | Most recent FICO lower bound |
| last_fico_range_high | int | Most recent FICO upper bound |
| dti | decimal(10,2) | Debt-to-income ratio |
| delinq_2yrs | int | Late payments in last 2 years |
| earliest_cr_line | date | Oldest credit account date |
| inq_last_6mths | int | Credit inquiries last 6 months |
| mths_since_last_delinq | int | Months since last late payment |
| mths_since_last_record | int | Months since last public record |
| open_acc | int | Open credit accounts |
| pub_rec | int | Derogatory public records |
| revol_bal | decimal(15,2) | Total revolving balance |
| revol_util | decimal(6,2) | Revolving utilisation rate |
| total_acc | int | Total credit accounts ever |
| acc_now_delinq | int | Currently delinquent accounts |
| tot_coll_amt | decimal(15,2) | Total collections ever owed |
| tot_cur_bal | decimal(15,2) | Total current balance |
| tot_hi_cred_lim | decimal(15,2) | Total high credit limit |
| total_bal_ex_mort | decimal(15,2) | Total balance ex-mortgage |
| total_bc_limit | decimal(15,2) | Total bankcard limit |
| pub_rec_bankruptcies | int | Bankruptcy records |
| tax_liens | int | Tax liens |
| mort_acc | int | Mortgage accounts |
| num_actv_bc_tl | int | Active bankcard accounts |
| num_actv_rev_tl | int | Active revolving accounts |
| num_bc_sats | int | Satisfactory bankcard accounts |
| num_bc_tl | int | Total bankcard accounts |
| num_il_tl | int | Instalment loan accounts |
| num_op_rev_tl | int | Open revolving accounts |
| num_rev_accts | int | Total revolving accounts |
| num_sats | int | Satisfactory accounts |
| pct_tl_nvr_dlq | decimal(6,2) | % accounts never delinquent |
| percent_bc_gt_75 | decimal(6,2) | % bankcards over 75% utilised |
| bc_util | decimal(6,2) | Bankcard utilisation rate |
| avg_cur_bal | decimal(15,2) | Average current balance |
| num_accts_ever_120_pd | int | Accounts ever 120 days past due |
| num_tl_90g_dpd_24m | int | Accounts 90+ DPD last 24 months |
| chargeoff_within_12_mths | int | Charge-offs within 12 months |
| delinq_amnt | decimal(15,2) | Delinquent amount |
| dti_flag | varchar(30) | Flags invalid DTI values |

**Cleaning notes:**
- 2,561 DTI values above 100 set to NULL
- 2 negative DTI values set to NULL
- dti_flag column added to preserve context

---

### fact_hardship
Loans placed on hardship programmes.
Only 832 rows — subset of accepted loans.

| Column | Type | Description |
|--------|------|-------------|
| hardship_id | int | PRIMARY KEY — auto increment |
| loan_id | varchar(50) | FOREIGN KEY → dim_loan_details |
| hardship_flag | varchar(5) | Y = on hardship plan |
| hardship_type | varchar(100) | Type of hardship |
| hardship_reason | varchar(100) | Reason for hardship |
| hardship_status | varchar(50) | Current hardship status |
| deferral_term | int | Months deferred |
| hardship_amount | decimal(15,2) | Amount under hardship |
| hardship_start_date | date | Plan start date |
| hardship_end_date | date | Plan end date |
| hardship_length | int | Duration in months |
| hardship_dpd | int | Days past due during hardship |
| hardship_loan_status | varchar(50) | Loan status during hardship |
| orig_projected_additional_accrued_interest | decimal(15,2) | Projected interest |
| hardship_payoff_balance_amount | decimal(15,2) | Balance at payoff |
| hardship_last_payment_amount | decimal(15,2) | Last payment amount |
| payment_plan_start_date | date | Payment plan start |

---

### fact_debt_settlement
Loans settled for less than the full amount owed.
34,246 rows — subset of accepted loans.

| Column | Type | Description |
|--------|------|-------------|
| settlement_id | int | PRIMARY KEY — auto increment |
| loan_id | varchar(50) | FOREIGN KEY → dim_loan_details |
| debt_settlement_flag | varchar(5) | Y = settlement occurred |
| debt_settlement_flag_date | date | When flag was raised |
| settlement_status | varchar(50) | Status of settlement |
| settlement_date | date | Settlement completion date |
| settlement_amount | decimal(15,2) | Amount settled for |
| settlement_percentage | decimal(6,2) | % of balance settled |
| settlement_term | int | Settlement term months |

---

## Foreign Key Relationships

| Child Table | Foreign Key | References |
|-------------|-------------|------------|
| dim_borrower | fk_borrower_loan | dim_loan_details(loan_id) |
| fact_loan_performance | fk_performance_loan | dim_loan_details(loan_id) |
| fact_credit_profile | fk_credit_loan | dim_loan_details(loan_id) |
| fact_hardship | fk_hardship_loan | dim_loan_details(loan_id) |
| fact_debt_settlement | fk_settlement_loan | dim_loan_details(loan_id) |

---

## Row Counts After All Cleaning

| Table | Row Count |
|-------|-----------|
| dim_loan_details | 2,260,668 |
| dim_borrower | 2260668 |
| dim_date | 4,748 |
| dim_rejected | 27,648,741 |
| fact_loan_performance | 2,260,668 |
| fact_credit_profile | 2,260,668 |
| fact_hardship | 832 |
| fact_debt_settlement | 34,246 |
| stg_accepted_loans | 2,260,701 |