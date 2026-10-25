# Clinical Trial Data Warehouse (dbt + DuckDB)

ELT pipeline that loads raw clinical trial extracts, cleans them with dbt, and builds a star schema ready for Power BI.

## Stack
Python, DuckDB, dbt Core, SQL, GitHub Actions

## Flow
1. `scripts/generate_raw.py` creates synthetic study, site, subject, visit and adverse event CSVs with deliberate data problems: duplicate rows, an orphan subject, a visit before enrollment, mixed sex codes, blank measurements.
2. `scripts/load_raw.py` loads the CSVs untouched into the `raw` schema (EL).
3. dbt staging views clean the data: dedupe, type casting, standardised codes.
4. dbt marts build a star schema: `dim_study`, `dim_site`, `dim_subject`, `dim_date`, `fact_visits`, `fact_adverse_events`, plus `rpt_site_enrollment` for BI.
5. `rejected_visits` quarantines invalid rows with a reason, so no row is lost silently.

## Data quality
41 checks run by `dbt build`: unique, not_null, relationships, accepted_values, and two singular tests: no visit before enrollment, and a row reconciliation (staged = loaded + rejected).

## Run
```
pip install -r requirements.txt
./run_pipeline.sh
```
Outputs `warehouse.duckdb`. Connect Power BI to the `marts` schema through the DuckDB ODBC driver, or export `rpt_site_enrollment` to CSV.

## Notes
Data is synthetic. DuckDB stands in for Snowflake so the project runs free and locally; the dbt models use standard SQL.
