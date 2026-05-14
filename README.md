# Credit Risk Analytics Project

## Overview
An end-to-end data analytics project analysing credit risk and loan portfolio 
performance using real-world Lending Club data (2007–2018).

Built to demonstrate professional-level skills in **MySQL** and **Power BI** 
within a credit lending business context.

---

## Business Questions This Project Answers
- What is the overall default rate across the loan portfolio?
- Which loan grades carry the highest risk of default?
- How does a borrower's DTI and FICO score affect loan performance?
- Which US states have the highest concentration of defaulted loans?
- What loan purposes are most likely to result in charge-offs?
- How has portfolio risk evolved from 2007 to 2018?
- What separates borrowers who fully repay from those who default?

---

## Dataset
| File | Records | Size |
|------|---------|------|
| accepted_2007_to_2018Q4.csv | 2,260,701 | 1.55 GB |
| rejected_2007_to_2018Q4.csv | 27,648,741 | 1.65 GB |

Source: [Lending Club Loan Data — Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club)

> Raw data files are not included in this repository due to size.
> Download from the link above and place in `Data/raw/`.

---

## Tools Used
| Tool | Purpose |
|------|---------|
| MySQL Workbench | Database design, data import, cleaning, analysis |
| Power BI Desktop | Interactive dashboard and visualisations |
| VS Code | Script editing and project documentation |
| GitHub | Version control and project portfolio |

---

## Database Schema
8-table star schema designed for analytical querying:

| Table | Type | Description |
|-------|------|-------------|
| dim_borrower | Dimension | Borrower identity and employment info |
| dim_loan_details | Dimension | Static loan attributes and terms |
| dim_date | Dimension | Calendar table for time intelligence |
| dim_rejected | Dimension | Rejected loan applications |
| fact_loan_performance | Fact | Loan status, payments and balances |
| fact_credit_profile | Fact | Credit bureau data at application time |
| fact_hardship | Fact | Hardship programme records |
| fact_debt_settlement | Fact | Debt settlement records |

---

## Project Phases
- [x] Phase 1 — Data Exploration
- [x] Phase 2 — Database Design & Schema Creation
- [x] Phase 3 — Data Import
- [x] Phase 4 — Data Cleaning
- [x] Phase 5 — SQL Analysis
- [x] Phase 6 — Power BI Dashboard

---

## Dashboard Preview

### Page 1 — Executive Summary
![Executive Summary](Docs/dashboard_page1_executive_summary.png)

### Page 2 — Risk Analysis
![Risk Analysis](Docs/dashboard_page2_risk_analysis.png)

### Page 3 — Portfolio Trends
![Portfolio Trends](Docs/dashboard_page3_portfolio_trends.png)

### Page 4 — Geographic Analysis
![Geographic Analysis](Docs/dashboard_page4_geographic.png)

### Page 5 — Borrower Profiles
![Borrower Profiles](Docs/dashboard_page5_borrower_profiles.png)

---

## Author
Oluwadunmininu Deborah Oluremi  
[LinkedIn](https://www.linkedin.com/in/dunmininu/)  
oluremid44@gmail.com