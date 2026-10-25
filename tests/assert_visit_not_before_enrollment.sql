-- singular test: a visit can never happen before the subject was enrolled
select v.visit_id
from {{ ref('fact_visits') }} v
join {{ ref('dim_subject') }} s on s.subject_key = v.subject_key
join {{ ref('dim_date') }} d on d.date_key = v.date_key
where d.date_day < s.enrollment_date
