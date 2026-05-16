# 📖 Enterprise Data Dictionary

> **Domain:** Consumer Credit Risk Analytics  
> **Portfolio:** Lending Club Portfolio Infrastructure (2007–2018)


## 📑 Table of Contents

1. [Data Ecosystem & Source Lineage](#data-ecosystem--source-lineage)
2. [Core Credit Risk Metadata & Glossary](#core-credit-risk-metadata--glossary)
3. [Domain A](#-domain-a-loan-origination--ingestion-metrics-dim_loan_details)
4. [Domain B](#-domain-b-borrower-demographics--personas-dim_borrower)
5. [Domain C](#%EF%B8%8F-domain-c-credit-bureau-snapshots-at-origination-fact_credit_profile)
6. [Domain D](#-domain-d-active-loan-performance--capital-loss-fact_loan_performance)
7. [Domain E](#-domain-e-portfolio-exception-handling--sparse-subsets-fact_hardship--fact_debt_settlement)
8. [Domain F](#-domain-f-global-time-intelligence-dim_date)
9. [Domain G](#-domain-g-standalone-pipeline-baseline-dim_rejected)
10. [Core Analytical Formula Matrix](#core-analytical-formula-matrix)
    
## Data Ecosystem & Source Lineage
*Establishing data provenance before defining individual fields.*

The infrastructure ingests raw, unstructured loan application data and transforms it into an analytics-ready warehouse layer.

|Ingestion Object | Database Target | Logical Grain | Strategic Value |
|-----------------|-----------------|---------------|-----------------|
|accepted_2007_to_2018Q4.csv | stg_accepted_loans | 1 Row per Funded Loan | Historical performance engine; tracks realization of credit risk over time. |
|rejected_2007_to_2018Q4.csv | dim_rejected | 1 Row per Declined App | Baseline population used to calculate institutional **Acceptance Rates.** |


## Core Credit Risk Metadata & Glossary
Grouped by Analytical Functional Domains data assets include;

### 🏦 Domain A: Loan Origination & Ingestion Metrics (dim_loan_details)
Descriptive, immutable attributes captured at the exact moment of credit approval. These fields establish the structural contract for the life of the asset.
|Column | Data Type | Constraint | Business Definition & Risk Relevance |
|-------|-----------|------------|--------------------------------------|
|loan_id | VARCHAR(50) | PRIMARY KEY | The unique, unmasked institutional identifier for each funded loan application. Acts as the primary join spine. |
|loan_amnt | DECIMAL(15,2) | Metric | The gross capital amount requested by the borrower during application submission. |
|funded_amnt | DECIMAL(15,2) | Metric | The total committed capital funded to the borrower by the lending institution. Baseline for exposure calculation. |
|funded_amnt_inv | DECIMAL(15,2) | Metric | The portion of the loan funded explicitly by fractional platform investors rather than institutional capital. |
|term | VARCHAR(20) | Attribute | The structured amortization window of the loan agreement (strictly capped at either 36 months or 60 months). |
|int_rate | DECIMAL(6,3) | Metric | The nominal annual interest rate charged to the borrower. Represents the gross yield premium. |
|installment | DECIMAL(10,2) | Metric | The mandatory fixed monthly payment amount owed by the borrower to service the debt. |
|grade | VARCHAR(5) | Categorical | Macro risk tier assigned by underwriting (A through G). Direct proxy for Probability of Default (PD). |
|sub_grade | VARCHAR(5) | Categorical | Granular risk sub-tier (A1 through G5) used for exact pricing and yield optimization. |
|purpose | VARCHAR(50) | Categorical | The borrower’s self-stated reason for requesting capital (e.g., debt_consolidation, small_business). |
|title | VARCHAR(200) | Text | Unstructured textual title provided by the borrower describing the loan intent.
|issue_d | DATE | FOREIGN KEY | The exact date the loan capital was disbursed. Joins directly to dim_date for time intelligence. |
|initial_list_status | VARCHAR(5) | Attribute | The operational listing status of the loan on the platform marketplace (W = Whole, F = Fractional). |
|disbursement_method | VARCHAR(20) | Attribute | The physical delivery system utilized to route the funds to the borrower (Cash or DirectPay). |
|policy_code | VARCHAR(10) | Metadata | Internal regulatory flag tracking the underwriting policy framework version applied to the application. |


### 👤 Domain B: Borrower Demographics & Personas (dim_borrower)
Socio-economic contextual markers used to construct behavioral profiles and isolate high-risk borrower clusters.
|Column | Data Type | Constraint | Business Definition & Risk Relevance |
|-------|-----------|------------|--------------------------------------|
|loan_id | VARCHAR(50) | FOREIGN KEY | Links directly back to dim_loan_details. Represents a 1:1 logical grain per loan. |
|emp_title | VARCHAR(100) | Text | Self-reported job title or profession of the primary applicant. |
|emp_length | VARCHAR(20) | Attribute | Employment tenure in years. Data Quality Fix: 222,556 missing values were cast to 'Not Specified' to preserve the missingness as an intentional risk signal. |
|home_ownership | VARCHAR(20) | Categorical | Housing tenure classification (RENT, OWN, MORTGAGE). Highly correlated with secondary credit access. |
|annual_inc | DECIMAL(15,2) | Metric | Self-reported gross annual income of the primary applicant. Used to evaluate baseline leverage. |
|addr_state | VARCHAR(5) | Categorical | Two-letter US state code. Used to isolate geographic concentration risk and state-level economic decay. |
|zip_code | VARCHAR(10) | Categorical | Three-digit masked postal code used for regional mapping while protecting borrower anonymity. |
|application_type | VARCHAR(20) | Categorical | Indicates whether the underwriting was performed for an Individual or a Joint co-signing population. |
|annual_inc_joint | DECIMAL(15,2) | Metric | Combined gross annual income of the joint applicants (populated only if application_type = 'Joint'). |

### 🛡️ Domain C: Credit Bureau Snapshots at Origination (fact_credit_profile)
The technical underwriting snapshot pulled from credit bureaus at the exact time of application. Used to evaluate pre-existing debt burden and payment discipline.

|Column | Data Type | Constraint | Business Definition & Risk Relevance |
|-------------|----------|-------|------|
|loan_id | VARCHAR(50) | FOREIGN KEY | Links directly back to dim_loan_details.v
|fico_range_low | INT | Metric | The baseline statistical floor of the borrower’s credit score at origination.|
|fico_range_high | INT | Metric | The upper bound of the borrower's credit score at origination.|
|last_fico_range_low | INT | Metric | The lowest boundary of the borrower's most recent credit score pull.|
|last_fico_range_high | INT | Metric | The highest boundary of the borrower's most recent credit score pull. Used to track score migration over time.|
|dti | DECIMAL(10,2) | Metric | Debt-to-Income ratio. Data Quality Fix: Outliers ($>100\%$ or $<0\%$) were nullified to protect analytical integrity.|
|dti_flag | VARCHAR(30) | Metadata | Engineered Column: Contextual flag mapping records as 'Valid', 'Exceeded 100%', or 'Missing' to retain audit transparency.|
|delinq_2yrs | INT | Metric | Number of 30+ days past due delinquency events on the borrower’s credit file within the past 24 months.|
|earliest_cr_line | DATE | Attribute | The origination date of the borrower's oldest active revolving credit line. Establishes credit history depth.|
|inq_last_6mths | INT | Metric | Number of hard credit inquiries within the past 6 months (excluding soft pulls). Proxy for credit hunger.|
|mths_since_last_delinq | INT | Metric | Months elapsed since the borrower's most recent delinquency event.|
|mths_since_last_record | INT | Metric | Months elapsed since the borrower's last public derogatory record (e.g., judgment, lien).|
|open_acc | INT | Metric | Count of active, open credit lines currently visible on the borrower's bureau profile.
|pub_rec | INT | Metric | Total count of derogatory public records on file.|
|revol_bal | DECIMAL(15,2) | Metric | Total outstanding dollar balance carried on the borrower's revolving credit accounts.|
|revol_util | DECIMAL(6,2) | Metric | Revolving credit utilization rate—total balance divided by maximum aggregate credit limits.|
|total_acc | INT | Metric | Aggregate count of all credit lines ever opened on the borrower's credit file (both active and closed).|
|acc_now_delinq | INT | Metric | Count of accounts on which the borrower is currently actively delinquent.|
|tot_coll_amt | DECIMAL(15,2) | Metric | Aggregate historical collection balances ever owed by the borrower.|
|tot_cur_bal | DECIMAL(15,2) | Metric | Aggregate current balance outstanding across all open accounts (including mortgage debt).|
|tot_hi_cred_lim | DECIMAL(15,2) | Metric | The maximum aggregate credit limit extended to the borrower across all lines.|
|total_bal_ex_mort | DECIMAL(15,2) | Metric | Aggregate current balance outstanding excluding real estate mortgage debt obligations.|
|total_bc_limit | DECIMAL(15,2) | Metric | Maximum aggregate credit limit specific to dedicated bankcard lines.|
|pub_rec_bankruptcies | INT | Metric | Total count of formal public bankruptcy filings visible on the record.|
|tax_liens | INT | Metric | Total count of active state or federal tax liens on the credit profile.|
|mort_acc | INT | Metric | Total number of real estate mortgage accounts on file.|
|num_actv_bc_tl | INT | Metric | Count of open bankcard accounts with active, non-zero transactional balances.|
|num_actv_rev_tl | INT | Metric | Count of open revolving accounts with active, non-zero transactional balances.|
|num_bc_sats | INT | Metric | Count of satisfactory, fully compliant bankcard accounts on the record.|
|num_bc_tl | INT | Metric | Gross aggregate count of bankcard accounts ever opened.|
|num_il_tl | INT | Metric | Gross aggregate count of installment loan accounts ever opened.|
|num_op_rev_tl | INT | Metric | Count of open, active revolving lines currently operational.|
|num_rev_accts | INT | Metric | Gross aggregate count of revolving accounts ever opened.|
|num_sats | INT | Metric | Total number of satisfactory accounts across the full bureau record.|
|pct_tl_nvr_dlq | DECIMAL(6,2) | Metric | The percentage of all credit lines that have never experienced a delinquency event.|
|percent_bc_gt_75 | DECIMAL(6,2) | Metric | The percentage of active bankcards currently exceeding a $75\%$ utilization limit. Strong default predictor.|
|bc_util | DECIMAL(6,2) | Metric | Explicit utilization rate across all bankcard lines.|
|avg_cur_bal | DECIMAL(15,2) | Metric | The mathematical average balance carried across all active accounts.|
|num_accts_ever_120_pd | INT | Metric | Total count of accounts that have ever lapsed into a severe 120+ days past due state.|
|num_tl_90g_dpd_24m | INT | Metric | Count of accounts severely delinquent by 90+ days within the tight 24-month window.|
|chargeoff_within_12_mths | INT | Metric | Number of structural asset write-offs/charge-offs on the borrower's record within the last 12 months.|
|delinq_amnt | DECIMAL(15,2) | Metric | The absolute current dollar amount past due on active delinquent accounts.|


### 💸 Domain D: Active Loan Performance & Capital Loss (fact_loan_performance)
Dynamic tracking metrics that record the modern repayment lifecycle, capturing default events and post-default recoveries.

|Column|Data Type|Constraint|Business Definition & Risk Relevance|
|------|---------|----------|------------------------------------|
|loan_id|VARCHAR(50)|FOREIGN KEY|Links directly back to dim_loan_details.|
|loan_status|VARCHAR(100)|Categorical|The live operational state of the asset (e.g., Fully Paid, Charged Off, Current).|
|out_prncp|DECIMAL(15,2)|Metric|Total outstanding unrecovered principal balance remaining on the asset book.|
|out_prncp_inv|DECIMAL(15,2)|Metric|Total outstanding unrecovered principal balance fractionally owed to platform investors.|
|total_pymnt|DECIMAL(15,2)|Metric|Gross aggregate capital successfully recovered from the borrower to date (Principal + Interest + Fees).|
|total_pymnt_inv|DECIMAL(15,2)|Metric|Gross aggregate capital successfully routed back to platform investors to date.|
|total_rec_prncp|DECIMAL(15,2)|Metric|The explicitly recovered principal component of the historical payments.|
|total_rec_int|DECIMAL(15,2)|Metric|The explicitly recovered interest component of the historical payments. Represents realized portfolio profit.|
|total_rec_late_fee|DECIMAL(10,2)|Metric|Aggregate punitive late fees collected from the borrower due to payment non-compliance.|
|recoveries|DECIMAL(15,2)|Metric|Post-default capital asset recoveries realized via third-party collections or asset sales.|
|collection_recovery_fee|DECIMAL(10,2)|Metric|Operational fees paid directly to collection agencies to realize the post-default recoveries.|
|last_pymnt_d|DATE|Attribute|Calendar date of the most recent transactional payment processed.|
|last_pymnt_amnt|DECIMAL(15,2)|Metric|Dollar value of the absolute last payment processed from the borrower.|
|next_pymnt_d|DATE|Attribute|Scheduled upcoming calendar date for the next contractual payment (applies only to active assets).|
|last_credit_pull_d|DATE|Attribute|The date of the absolute most recent credit bureau check executed on the borrower during the loan life.|
|pymnt_plan|VARCHAR(5)|Attribute|Binary flag indicating if the borrower has been placed on an active payment restructuring plan (y or n).|
|policy_exception|TINYINT(1)|Flag|Engineered audit flag identifying historical legacy loans originated under older policy framework revisions.|
|is_defaulted|TINYINT(1)|Flag|Engineered Boolean: Hardcoded 1 if asset status is Charged Off, Default, or Late (31-120 days). Normalizes risk rate logic.|
|is_concluded|TINYINT(1)|Flag|Engineered Boolean: Hardcoded 1 if asset has reached a terminal structural state (Fully Paid, Charged Off, Default).|


### 🚨 Domain E: Portfolio Exception Handling & Sparse Subsets (fact_hardship & fact_debt_settlement)
Specialized transaction dimensions containing information for loans requiring intense modification or negotiated write-offs. Kept decoupled to preserve core table performance.

#### Table 1: fact_hardship

|Column|Data Type|Business Definition & Risk Relevance|
|------|---------|------------------------------------|
|loan_id |VARCHAR(50) (FK)| References the central hub spine.|
|hardship_flag |VARCHAR(5)|: Categorical flag confirming active forbearance status.|
|hardship_type / hardship_reason |VARCHAR(100)| Explains structural rationale for payment modification (e.g., medical, unemployment).|
|hardship_status |VARCHAR(50) |Live operational state of the forbearance track (COMPLETED, BROKEN, ACTIVE).|
|deferral_term / hardship_length |INT |Contractual duration of the interest or payment suspension in months.|
|hardship_amount |DECIMAL(15,2) |Calculated monthly payment adjustment value during the deferral period.|
|hardship_start_date / hardship_end_date |DATE |Calendar limits of the authorized forbearance window.|
|payment_plan_start_date |DATE |Reactivation date for standard or restructured payment collections.|
|hardship_dpd |INT |Explicit Days Past Due counter recorded while operating inside the hardship modification track.|
|hardship_loan_status |VARCHAR(50) |The underlying loan state during intervention.|
|orig_projected_additional_accrued_interest |DECIMAL(15,2) |Financial estimate of delayed interest capitalization due to deferral.|
|hardship_payoff_balance_amount |DECIMAL(15,2)| Total principal payoff balance recorded at modification initiation.|
|hardship_last_payment_amount |DECIMAL(15,2)| Financial value of the final payment processed inside the hardship program.|


#### Table 2: fact_debt_settlement

|Column|Data Type|Business Definition & Risk Relevance|
|------|---------|------------------------------------|
|loan_id |VARCHAR(50), (FK)| References the central hub spine.|
|debt_settlement_flag |VARCHAR(5) |Confirms if a formal financial settlement agreement was successfully executed.|
|debt_settlement_flag_date |DATE |The exact calendar date the loss-mitigation flag was raised on system ledgers.|
|settlement_status |VARCHAR(50) |Live tracking status of the legal payment compromise (COMPLETE, ACTIVE, BROKEN).|
|settlement_date |DATE |The formal calendar completion date of the settlement negotiation transaction.|
|settlement_amount |DECIMAL(15,2) |The negotiated cash compromise value the borrower agreed to pay to satisfy the debt in full.|
|settlement_percentage |DECIMAL(6,2) |The financial ratio of the settlement amount relative to the gross outstanding balance owed at default.|
|settlement_term |INT |Allowed payment window in months to fully remit the negotiated settlement balance.|


### ⏳ Domain F: Global Time Intelligence (dim_date)
Unified calendar reference matrix used to eliminate complex date operations in DAX and SQL.

|Column|Data Type|Note|
|------|---------|------------------------------------|
|date_id |INT, (PK) | Formatted integer tracking dimension identity (YYYYMMDD).|
|full_date |DATE |Standard SQL structured date.|
|day / month / year|INT |Integer Extractions of the current date calendar markers.|
|month_name / day_name |VARCHAR(20) |Full textual names of the month and weekday entities for intuitive dashboard sorting.|
|quarter |INT |Calendar quarter tracker (1 through 4).|
|day_of_week |INT |Integer weekday index tracking sequence (1 through 7).|
|is_weekend |TINYINT(1) |Quick filter flag returning 1 if day falls on a Saturday or Sunday.|

### ❌ Domain G: Standalone Pipeline Baseline (dim_rejected)
Isolated application storage layer tracking structural credit requests declined by the underwriting model. Unlinked from accepted tables by design.

|Column|Data Type|Business Definition & Risk Relevance|
|------|---------|------------------------------------|
|rejected_id |INT (PK AI) |Unique row identity identifier.|
|amount_requested |DECIMAL(15,2)| Credit principal volume requested by the applicant.|
|application_date |DATE |Calendar date the request was denied.|
|loan_title |VARCHAR(200)| Unstructured text entry tracking requested loan purpose.|
|risk_score |DECIMAL(10,2) |Proprietary credit risk score applied to the applicant during the evaluation run.|
|dti_ratio |DECIMAL(10,2) |Aggregate monthly debt obligations divided by gross monthly income as computed at submission.|
|zip_code / state |VARCHAR |Regional geolocation tracking metrics for rejection concentration maps.|
|emp_length |VARCHAR(20) |Stated employment tenure of the declined applicant.|
|policy_code |VARCHAR(20) |Operational underwriting script framework version applied during the rejection decision rule.|

## Core Analytical Formula Matrix

To guarantee mathematical uniformity across the entire data engineering lifecycle; from raw table transformations to final dashboard measures all core performance, risk, and loss metrics are locked to the following structural formulas:

### 1. Concluded Default Rate (Portfolio Realized Risk)
Standard portfolio default rates can be artificially suppressed by a high volume of newly issued, un-matured active loans that haven't had time to fail yet. This metric isolates finalized outcomes to expose the true predictive accuracy of the underwriting model.

$$
\text{Concluded Default Rate \%} = \frac{\sum D}{\sum C} \times 100
$$

* **$\sum D$:** Cumulative count of unique assets where the loan defaulted (`is_defaulted` = 1).
* **$\sum C$:** Cumulative count of unique assets where the loan reached a terminal state (`is_concluded` = 1), encompassing `Fully Paid`, `Charged Off`, and `Default`.

---

### 2. Overall Portfolio Default Rate (Historical Exposure)
Measures the absolute saturation of default events across all originated historical assets within the warehouse, regardless of their current operational or maturity state.

$$
\text{Overall Default Rate \%} = \frac{\sum D}{N} \times 100
$$

* **$\sum D$:** Cumulative count of unique assets where the loan defaulted (`is_defaulted` = 1).
* **$N$:** Total row count of all approved loans in the system (`COUNT(loan_id)`).

---

### 3. Net Portfolio Loss (Capital Erosion)
Quantifies the absolute financial write-off value per asset. It measures the net dollar-value gap between the capital originally extended to the borrower and the cash recovered before or during the collection lifecycle.

$$
\text{Net Loss} = A_f - P_r
$$

* **$A_f$:** Gross principal capital funded to the borrower (`funded_amnt`).
* **$P_r$:** Explicit principal cash components successfully recovered from the borrower (`total_rec_prncp`).

---

### 4. Loss Given Default (LGD %)
Represents the percentage of the funded principal that is permanently lost when a loan transitions into a terminal default state, factoring in post-default asset recoveries.

$$
\text{Loss Given Default (LGD) \%} = \left( 1 - \frac{P_r + R}{A_f} \right) \times 100
$$

* **$P_r$:** Explicit principal cash components successfully recovered from the borrower (`total_rec_prncp`).
* **$R$:** Post-default cash collected via collections, modifications, or debt sales (`recoveries`).
* **$A_f$:** Gross principal capital funded to the borrower (`funded_amnt`).

---

### 5. Institutional Acceptance Rate %
Measures organizational risk appetite by evaluating the ratio of market loan demands approved and funded by the underwriting model relative to the gross aggregate application volume received.

$$
\text{Acceptance Rate \%} = \frac{A}{A + R_x} \times 100
$$

* **$A$:** Aggregate count of all approved and funded applications (`COUNT(dim_loan_details.loan_id)`).
* **$R_x$:** Aggregate count of all un-funded, declined applications (`COUNT(dim_rejected.rejected_id)`).

---

### 6. Debt-to-Income (DTI) Leverage Normalization
Calculates individual borrower financial extension by evaluating fixed monthly non-housing debt service liabilities relative to verified gross monthly income.

$$
\text{DTI Ratio} = \frac{M}{\left( \frac{I_a}{12} \right)} \times 100
$$

* **$M$:** Total monthly recurring debt obligations.
* **$I_a$:** Self-reported or verified gross annual income of the primary applicant (`annual_inc`).
