## Steps to Reproduce

1. Load Dataset
    * Download Power BI [Here](https://dev.mysql.com/downloads/connector/net/)
    * Connected to the Database with database details

2. Performed Query checks
    - Verified row counts
    - Ensured only data from the years we are analyseing were imported by using the Date filter 
    - Verified data types.

3. Data Modelling

|From| Table | Column | To Table | Column | Cardinality |
|----|-------|--------|----------|--------|-------------|
|fact_loan_performance | loan_id | dim_loan_details | loan_id | Many to One 
|fact_credit_profile | loan_id | dim_loan_details | loan_id | Many to One |
|fact_hardship | loan_id | dim_loan_details | loan_id | Many to One |
|fact_debt_settlement | loan_id | dim_loan_details | loan_id | Many to One |
|dim_borrower | loan_id | dim_loan_details | loan_id | Many to One |
|dim_loan_detail | sissue_d | dim_datefull_date | Many to One |

4. DAX Measures used included:
```dax
Total Approved Loans = COUNTROWS('lending_club_db fact_loan_performance')
```

```dax
Total Concluded = 
SUM('lending_club_db fact_loan_performance'[is_concluded])
```

```dax
Total Defaulted = 
CALCULATE(
    COUNTROWS('lending_club_db fact_loan_performance'), 
    'lending_club_db fact_loan_performance'[is_defaulted] = TRUE()
)
```

```dax
Total Recovered = 
SUM('lending_club_db fact_loan_performance'[total_rec_prncp])
```

```dax
Overall Default Rate % = 
DIVIDE(
    SUM('lending_club_db fact_loan_performance'[is_defaulted]),
    COUNTROWS('lending_club_db fact_loan_performance'),
    0
) * 100
```

```dax
Net Loss = 
SUMX(
    FILTER(
        'lending_club_db fact_loan_performance', 
        'lending_club_db fact_loan_performance'[is_defaulted] = TRUE()
    ),
    RELATED('lending_club_db dim_loan_details'[funded_amnt]) - 'lending_club_db fact_loan_performance'[total_rec_prncp]
)
```

```dax
Concluded Default Rate % = 
DIVIDE(
    SUMX('lending_club_db fact_loan_performance', INT('lending_club_db fact_loan_performance'[is_defaulted])),
    SUMX('lending_club_db fact_loan_performance', INT('lending_club_db fact_loan_performance'[is_concluded])),
    0
)
```

```dax
Acceptance Rate % = 
DIVIDE(
    COUNTROWS('lending_club_db fact_loan_performance'),
    COUNTROWS('lending_club_db fact_loan_performance') + COUNTROWS('lending_club_db dim_rejected'),
    0
) * 100
```

```dax
Avg Interest Rate % = 
AVERAGE('lending_club_db dim_loan_details'[int_rate])
```

```dax
Total Portfolio Value = 
SUM('lending_club_db dim_loan_details'[funded_amnt])
```

```dax
Total Rejected = 
COUNTROWS('lending_club_db dim_rejected')
```

```dax
Avg DTI = 
AVERAGE('lending_club_db fact_credit_profile'[dti])
```

```dax
Avg FICO Score = 
AVERAGE('lending_club_db fact_credit_profile'[fico_range_low])
```

```dax
Acceptance Rate % = 
DIVIDE(
    COUNTROWS('lending_club_db fact_loan_performance'),
    COUNTROWS('lending_club_db fact_loan_performance') + COUNTROWS('lending_club_db dim_rejected'),
    0
) * 100
```

4. Created a custom table "Fully Paid vs Defaulted Borrower Profile"
Found [here](Docs/dashboard_page5_borrower_profiles.png)


5. Further grouped purpose to keep major categories

    - Debt Financing
        - credit_card
        - debt_consolation
    - Education
        - educational
    - House
        - house
        - moving
    - Lifestlye
        - other
        - vacation
    - Major Asset
        - car
        - home_improvement
        - major_purchase
    - Medical
        - medical
    - Renewable Energy
        - renewable_energy
    - Small Business
        - small_business
    - Wedding
        - wedding

6. Graphs and Visuals
Built a 5 paged report dashboard

|Dashboard Page | What It Shows | View |
|---------------|---------------|------|
|Page 1 — Executive Summary | Headline KPIs, portfolio overview, rejection vs acceptance rate | [Executive Summary Page](Docs/dashboard_page1_executive_summary.png) |
|Page 2 — Risk Analysis | Default rate by grade, FICO band, DTI band | [Risk Analysis Page](Docs/dashboard_page2_risk_analysis.png) |
|Page 3 — Portfolio Trends | Monthly issuance growth, year over year default rate trend | [Portfolio Trend Page](Docs/dashboard_page3_portfolio_trends.png) |
|Page 4 — Geographic Analysis | US map of default rates by state| [Geographic Analysis Page](Docs/dashboard_page4_geographic.png) |
|Page 5 — Borrower Profiles | Defaulted vs fully paid comparison, employment and purpose breakdown | [Borrowers' Profile Page](Docs/dashboard_page5_borrower_profiles.png) |


Colour Palette:
- Background: #0D1B2A dark navy (Custom background built using Power Point)
- Card backgrounds: #1B2A3B
- Text: #E6E6E6 white
- Positive/safe: #2ECC71 green
- Warning: #F39C12 amber
- Danger/default: #E74C3C red
- Accent: #3498DB blue

All visuals have:
- No border
- Matching background to page
- White title text
- Consistent padding