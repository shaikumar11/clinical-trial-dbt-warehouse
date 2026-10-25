select
    row_number() over (order by study_id) as study_key,
    study_id, study_name, therapeutic_area, phase
from {{ ref('stg_studies') }}
