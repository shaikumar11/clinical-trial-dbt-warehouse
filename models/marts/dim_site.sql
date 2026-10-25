select
    row_number() over (order by s.site_id) as site_key,
    s.site_id, s.site_name, s.country, s.city,
    d.study_key
from {{ ref('stg_sites') }} s
join {{ ref('dim_study') }} d on d.study_id = s.study_id
