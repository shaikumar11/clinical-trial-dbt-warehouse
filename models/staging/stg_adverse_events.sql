select
    ae_id,
    subject_id,
    ae_term,
    severity,
    cast(ae_date as date) as ae_date
from {{ source('raw', 'adverse_events') }}
