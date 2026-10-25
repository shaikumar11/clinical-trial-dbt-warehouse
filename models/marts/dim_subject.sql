select
    row_number() over (order by s.subject_id) as subject_key,
    s.subject_id, s.age, s.sex, s.status, s.enrollment_date,
    d.site_key
from {{ ref('stg_subjects') }} s
join {{ ref('dim_site') }} d on d.site_id = s.site_id
