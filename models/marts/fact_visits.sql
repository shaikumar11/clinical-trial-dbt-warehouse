-- grain: one row per valid subject visit; invalid rows go to rejected_visits
select
    v.visit_id,
    s.subject_key,
    s.site_key,
    cast(strftime(v.visit_date, '%Y%m%d') as integer) as date_key,
    v.visit_type,
    v.systolic_bp,
    case when v.systolic_bp >= 140 then 1 else 0 end as high_bp_flag
from {{ ref('stg_visits') }} v
join {{ ref('dim_subject') }} s on s.subject_id = v.subject_id
where v.visit_date >= s.enrollment_date
