"""EL step: load raw CSV extracts into the DuckDB raw schema untouched (ELT, transform later in dbt)."""
import duckdb
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
DB = ROOT / "warehouse.duckdb"
TABLES = ["studies", "sites", "subjects", "visits", "adverse_events"]


def main():
    con = duckdb.connect(str(DB))
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")
    for t in TABLES:
        con.execute(f"CREATE OR REPLACE TABLE raw.{t} AS SELECT * FROM read_csv_auto('{(RAW / (t + '.csv')).as_posix()}', all_varchar=true)")
        n = con.execute(f"SELECT count(*) FROM raw.{t}").fetchone()[0]
        print(f"loaded raw.{t}: {n} rows")
    con.close()


if __name__ == "__main__":
    main()
