#!/usr/bin/env bash
set -euo pipefail
python scripts/generate_raw.py
python scripts/load_raw.py
dbt build --profiles-dir .
