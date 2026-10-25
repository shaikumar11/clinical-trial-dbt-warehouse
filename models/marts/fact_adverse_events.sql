-- grain: one row per adverse event
select
    a.ae_id,
    s.subject_key,
    s.site_key,
    cast(strftime(a.ae_date, '%Y%m%d') as integer) as date_key,
    a.ae_term,
    a.severity,
    case when a.severity = 'Severe' then 1 else 0 end as severe_flag
from {{ ref('stg_adverse_events') }} a
join {{ ref('dim_subject') }} s on s.subject_id = a.subject_id
