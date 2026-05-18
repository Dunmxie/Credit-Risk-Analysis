-- ============================================================
-- MASTER SCRIPT 01 — DATABASE SCHEMA
-- Project:  Credit Risk Analytics
-- 
-- Description:
--   Creates the lending_club_db database and all 9 tables
--   including the staging table, dimension tables, and fact
--   tables following a star schema design.
--
-- Tables Created:
--   1. stg_accepted_loans     (staging)
--   2. dim_borrower           (dimension)
--   3. dim_loan_details       (dimension)
--   4. dim_date               (dimension)
--   5. dim_rejected           (dimension)
--   6. fact_loan_performance  (fact)
--   7. fact_credit_profile    (fact)
--   8. fact_hardship          (fact)
--   9. fact_debt_settlement   (fact)
-- ============================================================


-- ============================================================
-- SECTION 1 — CREATE SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS lending_club_db;
USE lending_club_db;


-- ============================================================
-- SECTION 2 — STAGING TABLE
-- ============================================================

USE lending_club_db;

CREATE TABLE stg_accepted_loans (
    id                                      TEXT,
    member_id                               TEXT,
    loan_amnt                               TEXT,
    funded_amnt                             TEXT,
    funded_amnt_inv                         TEXT,
    term                                    TEXT,
    int_rate                                TEXT,
    installment                             TEXT,
    grade                                   TEXT,
    sub_grade                               TEXT,
    emp_title                               TEXT,
    emp_length                              TEXT,
    home_ownership                          TEXT,
    annual_inc                              TEXT,
    verification_status                     TEXT,
    issue_d                                 TEXT,
    loan_status                             TEXT,
    pymnt_plan                              TEXT,
    url                                     TEXT,
    description_text                        TEXT,
    purpose                                 TEXT,
    title                                   TEXT,
    zip_code                                TEXT,
    addr_state                              TEXT,
    dti                                     TEXT,
    delinq_2yrs                             TEXT,
    earliest_cr_line                        TEXT,
    fico_range_low                          TEXT,
    fico_range_high                         TEXT,
    inq_last_6mths                          TEXT,
    mths_since_last_delinq                  TEXT,
    mths_since_last_record                  TEXT,
    open_acc                                TEXT,
    pub_rec                                 TEXT,
    revol_bal                               TEXT,
    revol_util                              TEXT,
    total_acc                               TEXT,
    initial_list_status                     TEXT,
    out_prncp                               TEXT,
    out_prncp_inv                           TEXT,
    total_pymnt                             TEXT,
    total_pymnt_inv                         TEXT,
    total_rec_prncp                         TEXT,
    total_rec_int                           TEXT,
    total_rec_late_fee                      TEXT,
    recoveries                              TEXT,
    collection_recovery_fee                 TEXT,
    last_pymnt_d                            TEXT,
    last_pymnt_amnt                         TEXT,
    next_pymnt_d                            TEXT,
    last_credit_pull_d                      TEXT,
    last_fico_range_high                    TEXT,
    last_fico_range_low                     TEXT,
    collections_12_mths_ex_med              TEXT,
    mths_since_last_major_derog             TEXT,
    policy_code                             TEXT,
    application_type                        TEXT,
    annual_inc_joint                        TEXT,
    dti_joint                               TEXT,
    verification_status_joint               TEXT,
    acc_now_delinq                          TEXT,
    tot_coll_amt                            TEXT,
    tot_cur_bal                             TEXT,
    open_acc_6m                             TEXT,
    open_act_il                             TEXT,
    open_il_12m                             TEXT,
    open_il_24m                             TEXT,
    mths_since_rcnt_il                      TEXT,
    total_bal_il                            TEXT,
    il_util                                 TEXT,
    open_rv_12m                             TEXT,
    open_rv_24m                             TEXT,
    max_bal_bc                              TEXT,
    all_util                                TEXT,
    total_rev_hi_lim                        TEXT,
    inq_fi                                  TEXT,
    total_cu_tl                             TEXT,
    inq_last_12m                            TEXT,
    acc_open_past_24mths                    TEXT,
    avg_cur_bal                             TEXT,
    bc_open_to_buy                          TEXT,
    bc_util                                 TEXT,
    chargeoff_within_12_mths               TEXT,
    delinq_amnt                             TEXT,
    mo_sin_old_il_acct                      TEXT,
    mo_sin_old_rev_tl_op                    TEXT,
    mo_sin_rcnt_rev_tl_op                   TEXT,
    mo_sin_rcnt_tl                          TEXT,
    mort_acc                                TEXT,
    mths_since_recent_bc                    TEXT,
    mths_since_recent_bc_dlq               TEXT,
    mths_since_recent_inq                   TEXT,
    mths_since_recent_revol_delinq         TEXT,
    num_accts_ever_120_pd                   TEXT,
    num_actv_bc_tl                          TEXT,
    num_actv_rev_tl                         TEXT,
    num_bc_sats                             TEXT,
    num_bc_tl                               TEXT,
    num_il_tl                               TEXT,
    num_op_rev_tl                           TEXT,
    num_rev_accts                           TEXT,
    num_rev_tl_bal_gt_0                     TEXT,
    num_sats                                TEXT,
    num_tl_120dpd_2m                        TEXT,
    num_tl_30dpd                            TEXT,
    num_tl_90g_dpd_24m                      TEXT,
    num_tl_op_past_12m                      TEXT,
    pct_tl_nvr_dlq                          TEXT,
    percent_bc_gt_75                        TEXT,
    pub_rec_bankruptcies                    TEXT,
    tax_liens                               TEXT,
    tot_hi_cred_lim                         TEXT,
    total_bal_ex_mort                       TEXT,
    total_bc_limit                          TEXT,
    total_il_high_credit_limit              TEXT,
    revol_bal_joint                         TEXT,
    sec_app_fico_range_low                  TEXT,
    sec_app_fico_range_high                 TEXT,
    sec_app_earliest_cr_line                TEXT,
    sec_app_inq_last_6mths                  TEXT,
    sec_app_mort_acc                        TEXT,
    sec_app_open_acc                        TEXT,
    sec_app_revol_util                      TEXT,
    sec_app_open_act_il                     TEXT,
    sec_app_num_rev_accts                   TEXT,
    sec_app_chargeoff_within_12_mths        TEXT,
    sec_app_collections_12_mths_ex_med      TEXT,
    sec_app_mths_since_last_major_derog     TEXT,
    hardship_flag                           TEXT,
    hardship_type                           TEXT,
    hardship_reason                         TEXT,
    hardship_status                         TEXT,
    deferral_term                           TEXT,
    hardship_amount                         TEXT,
    hardship_start_date                     TEXT,
    hardship_end_date                       TEXT,
    payment_plan_start_date                 TEXT,
    hardship_length                         TEXT,
    hardship_dpd                            TEXT,
    hardship_loan_status                    TEXT,
    orig_projected_additional_accrued_interest TEXT,
    hardship_payoff_balance_amount          TEXT,
    hardship_last_payment_amount            TEXT,
    disbursement_method                     TEXT,
    debt_settlement_flag                    TEXT,
    debt_settlement_flag_date               TEXT,
    settlement_status                       TEXT,
    settlement_date                         TEXT,
    settlement_amount                       TEXT,
    settlement_percentage                   TEXT,
    settlement_term                         TEXT
);

-- ============================================================
-- SECTION 3 — DIMENSION TABLES
-- ============================================================

CREATE TABLE dim_borrower (
    member_id         VARCHAR(50) PRIMARY KEY,
    emp_title         VARCHAR(100),
    emp_length        VARCHAR(20),
    home_ownership    VARCHAR(20),
    annual_inc        DECIMAL(15,2),
    addr_state        VARCHAR(5),
    zip_code          VARCHAR(10),
    application_type  VARCHAR(20),
    annual_inc_joint  DECIMAL(15,2)
);

-- dim_loan_details:
CREATE TABLE dim_loan_details (
    loan_id           VARCHAR(50) PRIMARY KEY,
    loan_amnt         DECIMAL(15,2),
    funded_amnt       DECIMAL(15,2),
    funded_amnt_inv   DECIMAL(15,2),
    term              VARCHAR(20),
    int_rate          DECIMAL(6,3),
    installment       DECIMAL(10,2),
    grade             VARCHAR(5),
    sub_grade         VARCHAR(5),
    purpose           VARCHAR(50),
    title             VARCHAR(200),
    issue_d           DATE,
    initial_list_status VARCHAR(5),
    disbursement_method VARCHAR(20),
    policy_code       VARCHAR(10)
);

-- dim_date:
CREATE TABLE dim_date (
    date_id       INT PRIMARY KEY,
    full_date     DATE,
    day           INT,
    month         INT,
    month_name    VARCHAR(20),
    quarter       INT,
    year          INT,
    day_of_week   INT,
    day_name      VARCHAR(20),
    is_weekend    BOOLEAN
);

-- dim_rejected:
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


-- ============================================================
-- SECTION 4 — FACT TABLES
-- ============================================================

-- fact_loan_performance:
CREATE TABLE fact_loan_performance (
    loan_id               VARCHAR(50) PRIMARY KEY,
    borrower_id           INT,
    loan_status           VARCHAR(100),
    out_prncp             DECIMAL(15,2),
    out_prncp_inv         DECIMAL(15,2),
    total_pymnt           DECIMAL(15,2),
    total_pymnt_inv       DECIMAL(15,2),
    total_rec_prncp       DECIMAL(15,2),
    total_rec_int         DECIMAL(15,2),
    total_rec_late_fee    DECIMAL(10,2),
    recoveries            DECIMAL(15,2),
    collection_recovery_fee DECIMAL(10,2),
    last_pymnt_d          DATE,
    last_pymnt_amnt       DECIMAL(15,2),
    next_pymnt_d          DATE,
    last_credit_pull_d    DATE,
    pymnt_plan            VARCHAR(5)
);

-- fact_credit_profile:
CREATE TABLE fact_credit_profile (
    loan_id                   VARCHAR(50) PRIMARY KEY,
    borrower_id               INT,
    fico_range_low            INT,
    fico_range_high           INT,
    last_fico_range_low       INT,
    last_fico_range_high      INT,
    dti                       DECIMAL(10,2),
    delinq_2yrs               INT,
    earliest_cr_line          DATE,
    inq_last_6mths            INT,
    mths_since_last_delinq    INT,
    mths_since_last_record    INT,
    open_acc                  INT,
    pub_rec                   INT,
    revol_bal                 DECIMAL(15,2),
    revol_util                DECIMAL(6,2),
    total_acc                 INT,
    acc_now_delinq            INT,
    tot_coll_amt              DECIMAL(15,2),
    tot_cur_bal               DECIMAL(15,2),
    tot_hi_cred_lim           DECIMAL(15,2),
    total_bal_ex_mort         DECIMAL(15,2),
    total_bc_limit            DECIMAL(15,2),
    pub_rec_bankruptcies      INT,
    tax_liens                 INT,
    mort_acc                  INT,
    num_actv_bc_tl            INT,
    num_actv_rev_tl           INT,
    num_bc_sats               INT,
    num_bc_tl                 INT,
    num_il_tl                 INT,
    num_op_rev_tl             INT,
    num_rev_accts             INT,
    num_sats                  INT,
    pct_tl_nvr_dlq            DECIMAL(6,2),
    percent_bc_gt_75          DECIMAL(6,2),
    bc_util                   DECIMAL(6,2),
    avg_cur_bal               DECIMAL(15,2),
    num_accts_ever_120_pd     INT,
    num_tl_90g_dpd_24m        INT,
    chargeoff_within_12_mths  INT,
    delinq_amnt               DECIMAL(15,2)
);

-- fact_hardship:
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

-- fact_debt_settlement:
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
