ReadMe for System Diagram on Draw.io
---
Visualisation Description: End-to-end modern data stack (ELT) architecture illustrating raw data ingestion, dimensional transformation via dbt, automated quality validation, and downstream analytics visualization.

## Tools Used

  - Google BigQuery
  - dbt
  - Great Expectations
  - Python
  - matplotlib
---

# Data Engineering Pipeline Overview

End-to-end modern data stack (ELT) architecture illustrating raw data ingestion, dimensional transformation via `dbt`, automated quality validation, and downstream analytics visualization.

---

## Architecture Flow

[Kaggle CSV/Sources]
│ (ELT Pipeline)
▼
[Google BigQuery: Ingestion & Staging]
│
▼
[dbt Dimensional Modeling (Star Schema)]
├── Dimensions: dim_customers, dim_product
└── Facts: fact_orders, fact_order_items
│
▼
[Great Expectations: Quality Testing]
├── Is Not Null [PASS]
└── Assert Type Match [PASS]
│
▼
[Python + Matplotlib: Analysis & Visualization]


---

## Pipeline Stages

### 1. Data Ingestion & GCP BigQuery
* **Source**: Raw data files (e.g., CSV datasets from Kaggle).
* **Load Pattern**: ELT (Extract, Load, Transform) pipeline moving raw files directly into Google Cloud storage layers.
* **Storage**: Google BigQuery organized into **Ingestion** and **Staging** layers.

### 2. dbt Modeling & Star Schema
* **Tool**: `dbt` (data build tool).
* **Data Mart Structure**: Dimensional modeling implementing a **Star Schema**:
  * **Dimensions**: `dim_customers`, `dim_product`
  * **Facts**: `fact_orders`, `fact_order_items`
* **Metrics/Aggregations**: Business logic evaluation (e.g., performance metrics tracking).

### 3. Data Quality Testing
* **Tool**: Great Expectations.
* **Assertions & Validations**:
  * `Is Not Null` — **PASS**
  * `Assert Type Match` — **PASS**

### 4. Python Analysis & Visualization
* **Stack**: Python + `matplotlib`.
* **Output**: Dashboards, charts, and visual reporting derived from clean, tested data marts.

#### Pareto (80/20 Rule) in Analytics
* **Application**: Identify the vital few drivers of business value (e.g., top 20% of products driving 80% of revenue from `fact_order_items`).
* **Python Implementation**: Group data by SKU/customer dimensions, compute cumulative sum percentages, and plot Pareto Lorenz curves using `matplotlib` dual-axis charts (`bar` for individual contribution, `line` for cumulative percentage).
* **Decision Impact**: Prioritize inventory optimization, marketing spend, or quality alerts on the high-impact segment.

#### Diffusion of Innovation in Analytics
* **Application**: Segment user adoption or feature rollout velocity over time across customer cohorts (`dim_customers`).
* **Python Implementation**: Track cumulative adoption curves (innovators, early adopters, early majority, late majority, laggards) using time-series aggregations and derivative velocity plots (S-curve fitting with `scipy.optimize` and `matplotlib`).
* **Decision Impact**: Determine inflection points for scaling product feature releases or adjusting customer success interventions.

---

## Tech Stack Summary
| Layer | Technology | Role |
| :--- | :--- | :--- |
| **Ingestion / Warehouse** | Google BigQuery | Raw storage, staging, and data warehousing |
| **Transformation** | dbt | Dimensional SQL modeling (Star Schema) |
| **Quality / Testing** | Great Expectations | Schema and null-check assertions |
| **Consumption / Viz** | Python / matplotlib | Exploratory analysis, Pareto, and adoption modeling |