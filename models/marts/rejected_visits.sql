-- quarantine table: visits that failed validation, with the reason, so no row disappears silently
select
    v.visit_id,
    v.subject_id,
    v.visit_date,
    case
        when s.subject_id is null              then 'unknown subject'
        when v.visit_date < s.enrollment_date  then 'visit before enrollment'
    end as reject_reason
from {{ ref('stg_visits') }} v
left join {{ ref('stg_subjects') }} s on s.subject_id = v.subject_id
where s.subject_id is null or v.visit_date < s.enrollment_date
