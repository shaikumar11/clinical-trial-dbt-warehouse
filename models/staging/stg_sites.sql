select
    site_id,
    study_id,
    site_name,
    country,
    city
from {{ source('raw', 'sites') }}
