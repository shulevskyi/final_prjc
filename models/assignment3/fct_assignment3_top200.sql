{{ config(materialized='table') }}

with base as (
  select
    title,
    src,
    count(*) as views
  from {{ ref('int_assignment3_uk_wiki') }}
  where is_meta_page = false  -- Exclude meta pages
  group by title, src
),

agg as (
  select
    title,
    sum(views) as total_views,
    sum(case when src = 'mobile' then views else 0 end) as total_mobile_views
  from base
  group by title
)

select
  title,
  total_views,
  total_mobile_views,
  round(safe_divide(total_mobile_views, total_views) * 100, 2) as mobile_percentage
from agg
order by mobile_percentage asc
limit 200

