{{ config(materialized='table') }}

with filtered as (
  -- Filter the data to include only rows for "Риджент-стріт"
  select *
  from {{ ref('int_assignment3_uk_wiki') }}
  where title = 'Риджент-стріт'
),

hourly as (
  -- Group the filtered data by hour of day
  select
    extract(hour from datehour) as hour_of_day,
    count(*) as total_views,
    sum(case when src = 'mobile' then 1 else 0 end) as total_mobile_views
  from filtered
  group by extract(hour from datehour)
)

select
  hour_of_day,
  total_views,
  total_mobile_views,
  round(safe_divide(total_mobile_views, total_views) * 100, 2) as mobile_percentage
from hourly
order by hour_of_day

