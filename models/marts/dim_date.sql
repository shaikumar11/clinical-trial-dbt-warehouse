with bounds as (
    select min(visit_date) as d0, max(visit_date) as d1 from {{ ref('stg_visits') }}
),
days as (
    select cast(unnest(generate_series(d0, d1, interval 1 day)) as date) as date_day from bounds
)
select
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    date_day,
    year(date_day)   as year,
    month(date_day)  as month,
    strftime(date_day, '%B') as month_name,
    quarter(date_day) as quarter
from days
