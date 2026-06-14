# E-commerce Sales Analytics
**Tools:** Python (Pandas) · SQL (SQLite) · Power BI

End-to-end analysis of 5,000+ e-commerce transactions —
from messy raw data to an interactive dashboard.

---

## What I did

### 1. Data Cleaning (Pandas)
- Removed 80 duplicate rows
- Fixed mixed date formats (YYYY-MM-DD and DD/MM/YYYY)
- Standardized inconsistent category labels (e.g. "electronics" → "Electronics")
- Imputed missing quantity values using per-category median
- Flagged price outliers using IQR method
- Engineered new features: fulfillment days, order quarter, customer LTV

### 2. SQL Analysis
8 business questions answered using CTEs, window functions, and conditional aggregation.

**Key queries:**
- Month-over-month revenue growth using `LAG()`
- Cities ranked within region using `RANK() OVER (PARTITION BY)`
- Cohort retention analysis across 24 months
<img width="1074" height="510" alt="image" src="https://github.com/user-attachments/assets/8c1d9c90-e82b-481c-bec8-0dde52afa4b3" />

<img width="1230" height="1142" alt="image" src="https://github.com/user-attachments/assets/4b229a75-5e22-41cd-b897-0e1c3a153c9e" />



### 3. Power BI Dashboard

<img width="574" height="325" alt="image (4)" src="https://github.com/user-attachments/assets/2063da83-c45c-4193-8c96-944ab37b5b47" />
<img width="576" height="326" alt="image (5)" src="https://github.com/user-attachments/assets/0308a43e-d4f6-40de-babb-b3fb00a87cad" />
<img width="573" height="326" alt="image (6)" src="https://github.com/user-attachments/assets/8d796e1e-700d-4685-bd4e-9e74481fdc2d" />


---

## Key Insights
- **VIP customers (15% of users) drove 38% of total revenue**
- **Electronics had the lowest return rate (4.8%)** despite being the highest AOV category
- **Discounts above 15% did not increase average order value** — margin cost with no basket size benefit
- **West region had the highest AOV ($187)** despite fewer orders than East
- **Q4 2024 revenue was up 22% YoY**, driven by Electronics and Home & Garden

---

## Files
| File | Description |
|---|---|
| `pandas/01_pandas_cleaning.py` | Full cleaning script with comments |
| `sql/sql_queries.sql` | All 8 business questions |
| `sql/results/` | CSV output for each query |
| `screenshots/` | Query outputs + dashboard |
