# Clinical Trial Data Warehouse

![CI](https://github.com/shaikumar11/clinical-trial-dbt-warehouse/actions/workflows/ci.yml/badge.svg)
![dbt](https://img.shields.io/badge/dbt-core-orange) ![DuckDB](https://img.shields.io/badge/DuckDB-warehouse-yellow) ![Python](https://img.shields.io/badge/Python-3.11-blue)

An ELT pipeline that loads raw clinical trial extracts into a warehouse, cleans and models them with **dbt**, and publishes a **star schema** and a reporting table ready for Power BI.

## Why this project
Clinical research teams need trustworthy site, subject and safety data. This project shows the full path from messy source files to tested, analysis-ready tables: loading, cleaning, dimensional modelling, data quality testing and CI.

## Architecture

```mermaid
flowchart LR
    A[Source CSV extracts] -->|load_raw.py| B[(raw schema)]
    B -->|dbt staging views| C[stg_ models: dedupe, cast, standardise]
    C -->|dbt marts| D[Star schema: dim_ and fact_ tables]
    C -->|validation rules| E[rejected_visits]
    D --> F[rpt_site_enrollment]
    F --> G[Power BI]
```

## Star schema

```mermaid
erDiagram
    dim_study ||--o{ dim_site : has
    dim_site ||--o{ dim_subject : enrols
    dim_subject ||--o{ fact_visits : attends
    dim_subject ||--o{ fact_adverse_events : reports
    dim_date ||--o{ fact_visits : on
    dim_date ||--o{ fact_adverse_events : on
```

| Table | Grain | Purpose |
|---|---|---|
| `dim_study` | one row per study | therapeutic area and phase |
| `dim_site` | one row per site | country and city, linked to study |
| `dim_subject` | one row per subject | age, sex, status, enrolment date, linked to site |
| `dim_date` | one row per day | year, month, quarter for time analysis |
| `fact_visits` | one row per valid visit | visit type, systolic BP, high BP flag |
| `fact_adverse_events` | one row per adverse event | term, severity, severe flag |
| `rpt_site_enrollment` | one row per site | subjects, withdrawal rate, adverse events for dashboards |
| `rejected_visits` | one row per invalid visit | rejected rows with a reason |

## Data quality
The source data is synthetic and deliberately messy. The pipeline handles:

| Problem in source | How it is handled |
|---|---|
| Exact duplicate visit and subject rows | removed in staging |
| Sex coded as M, f, Male, Female | standardised to Male, Female, Unknown |
| Blank blood pressure values | converted to NULL |
| Visit for a subject that does not exist | sent to `rejected_visits` as unknown subject |
| Visit dated before enrolment | sent to `rejected_visits` as visit before enrollment |

`dbt build` runs **41 checks**: unique, not_null, relationships, accepted_values, and two custom tests:
- no visit may occur before the subject was enrolled
- row reconciliation: staged visits = loaded visits + rejected visits, so no row is lost silently

## Project structure

```
scripts/generate_raw.py   creates synthetic source CSVs
scripts/load_raw.py       loads CSVs into the raw schema
models/staging/           cleaning views
models/marts/             dimensions, facts, report, rejected rows
tests/                    custom data tests
.github/workflows/ci.yml  runs the full pipeline on every push
```

## How to run

```
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r requirements.txt

python scripts/generate_raw.py
python scripts/load_raw.py
dbt build --profiles-dir .
```

On Linux or Mac, `./run_pipeline.sh` runs the same three steps.

Expected result: `Done. PASS=41 WARN=0 ERROR=0`

## Example queries

```sql
-- sites with the highest withdrawal rate
select study_name, site_name, country, withdrawal_rate_pct
from main_marts.rpt_site_enrollment
order by withdrawal_rate_pct desc
limit 5;

-- rows rejected and why
select reject_reason, count(*) from main_marts.rejected_visits group by 1;
```

## Using it with Power BI
Export `rpt_site_enrollment` and the fact and dimension tables from `warehouse.duckdb` to CSV, or connect through the DuckDB ODBC driver, then build site enrolment, withdrawal and safety dashboards.

## Notes
- All data is synthetic. No real patient data is used.
- DuckDB stands in for a cloud warehouse such as Snowflake so the project runs locally and free. The dbt models use standard SQL.
