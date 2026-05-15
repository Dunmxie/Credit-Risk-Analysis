# 📑 Strategic Risk Analysis Report

 **Project:** Lending Club Portfolio Diagnostic (2007–2018)  
 **Analyst:** Oluwadunmininu Deborah Oluremi  
 **Status:** High-Risk Portfolio Review

## 🚩 Executive Summary: The Vitals
The Lending Club portfolio is currently in a state of **quality decay**. While issuance volume has scaled 3.6x, the **Concluded Default Rate** (21.57%) indicates that nearly 1 in 5 loans results in capital erosion.

|Metric | Performance | Strategic Note|
|-------|-------------|----------|
|Total Volume | 2.26M Approved | Massive scale, high operational complexity. |
|Default Rate | 21.57% (Concluded) | **Critical.** Exceeds sustainable yield thresholds. |
|Portfolio Value | ~$56.4 Billion | High-stakes exposure requiring rigorous hedging. |
|Selectivity | 92.4% Rejection | Despite high rejection, credit leakage remains high. |

## 🔍 Domain 1: Credit Tiering & Underwriting Efficiency
**Finding:** The yield-risk gap in bottom-tier grades.
- **The Grade G Paradox:** Grade G loans carry a 52.20% default rate. With an average interest rate of 28%, the math fails: the bank loses more in principal than it gains in interest. This is a **negative expected value (EV)** segment.

- **FICO Sensitivity:** 71% of the portfolio is concentrated in the 670-739 (Good) band. This creates **Cluster Risk**; a minor economic downturn would impact the vast majority of the loan book simultaneously.

## 📈 Domain 2: The Macro Growth-Quality Tradeoff
**Finding:** Aggressive scaling led to adverse selection.
- **Vintage Deterioration:** Between 2013 and 2018, default rates climbed from **15.6% to 28.6%**.

- **The Scaling Trap:** The data suggests that to achieve the 495K annual issuance peak in 2018, underwriting standards were likely compromised. The bank prioritized **market share over margin**, leading to a 2x decay in credit quality.

## 🗺️ Domain 3: Geographic & Behavioral Variance
**Finding:** External environment outweighs individual credit scores.
- **The Geography Alpha:** Mississippi (**29.25% default**) significantly underperforms Washington DC (14.40%) despite identical FICO/DTI profiles.
    - Insight: Geography is a **proxy for local economic resilience**. The model is currently under-pricing regional volatility.

- **The Information Gap Risk:** Borrowers who fail to specify employment length default at **29.28%** (a 9% premium over those with 10+ years).
    - Insight: **Data opacity is a risk signal.** Incomplete profiles should be treated as high-risk, regardless of FICO score.

## 💡 The Default Persona vs. Repayer
Contrary to intuition, defaulters do not look bad on paper, they look **stressed**.
|Metric | Repayer | Defaulter | Variance |
|-------|---------|-----------|-----------|
|Income | $77,000 | $70,000 | -9% |
|FICO | 698 | 688 | -10 pts |
|DTI | 17.7% | 20.0% | +2.3% |
|Interest Rate | 12.6% | 15.7% | +3.1% |

Tis tells us defaulters aren't necessarily irresponsible; they are mathematically squeezed by slightly lower incomes and higher debt costs, leaving no margin for financial shocks.

## 🛠️ Strategic Recommendations
1. **Eliminate Grade G:** Terminate originations in this segment; the loss rate exceeds potential interest revenue.
2. **Regional Risk Load:** Implement a **+2.5% interest rate premium** for borrowers in high-default states (MS, AL, AR) to compensate for localized economic volatility.
3. **Strict Verification:** Mandate employment verification. The Not Specified segment is a preventable source of portfolio loss.
4. **DTI Ceiling:** Implement a hard-cap of **35% DTI** for unsecured loans to increase the buffer against default.