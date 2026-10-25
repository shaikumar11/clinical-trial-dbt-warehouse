-- reconciliation: every staged visit is either in fact_visits or in rejected_visits, never lost
with staged   as (select count(*) as n from {{ ref('stg_visits') }}),
     loaded   as (select count(*) as n from {{ ref('fact_visits') }}),
     rejected as (select count(*) as n from {{ ref('rejected_visits') }})
select 1
from staged, loaded, rejected
where staged.n <> loaded.n + rejected.n
