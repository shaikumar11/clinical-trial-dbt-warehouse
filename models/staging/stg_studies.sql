select
    study_id,
    study_name,
    therapeutic_area,
    phase
from {{ source('raw', 'studies') }}
