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
> Download from the link above and place in `data/raw/`.

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
- [ ] Phase 3 — Data Import
- [ ] Phase 4 — Data Cleaning
- [ ] Phase 5 — SQL Analysis
- [ ] Phase 6 — Power BI Dashboard

---

## Author
Oluwadunmininu Deborah Oluremi  
[LinkedIn](https://www.linkedin.com/in/dunmininu/)  
oluremid44@gmail.com