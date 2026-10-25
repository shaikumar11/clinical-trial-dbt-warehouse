-- reporting mart for BI tools such as Power BI: one row per site
select
    st.study_name,
    si.site_name,
    si.country,
    count(distinct sub.subject_key)                          as subjects_enrolled,
    count(distinct case when sub.status = 'Withdrawn' then sub.subject_key end) as subjects_withdrawn,
    round(100.0 * count(distinct case when sub.status = 'Withdrawn' then sub.subject_key end)
          / count(distinct sub.subject_key), 1)              as withdrawal_rate_pct,
    count(distinct ae.ae_id)                                 as adverse_events,
    count(distinct case when ae.severe_flag = 1 then ae.ae_id end) as severe_adverse_events
from {{ ref('dim_site') }} si
join {{ ref('dim_study') }} st on st.study_key = si.study_key
join {{ ref('dim_subject') }} sub on sub.site_key = si.site_key
left join {{ ref('fact_adverse_events') }} ae on ae.subject_key = sub.subject_key
group by 1, 2, 3
