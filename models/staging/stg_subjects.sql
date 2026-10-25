-- remove duplicate subject rows, cast types, standardise sex codes
with deduped as (
    select distinct * from {{ source('raw', 'subjects') }}
)
select
    subject_id,
    site_id,
    cast(enrollment_date as date) as enrollment_date,
    cast(age as integer)          as age,
    case upper(left(sex, 1)) when 'M' then 'Male' when 'F' then 'Female' else 'Unknown' end as sex,
    status
from deduped
