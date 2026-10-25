-- remove duplicates, cast types, turn blank measurements into nulls
with deduped as (
    select distinct * from {{ source('raw', 'visits') }}
)
select
    visit_id,
    subject_id,
    visit_type,
    cast(visit_date as date)                    as visit_date,
    try_cast(nullif(systolic_bp, '') as integer) as systolic_bp
from deduped
