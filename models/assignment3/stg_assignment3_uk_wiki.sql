{{ config(materialized='view') }}

with desktop as (
  select
    'desktop' as src,
    title,
    datehour
  from {{ source('test_dataset', 'assignment3_input_uk') }}
),

mobile as (
  select
    'mobile' as src,
    title,
    datehour
  from {{ source('test_dataset', 'assignment3_input_uk_m') }}
),

unioned as (
  select * from desktop
  union all
  select * from mobile
)

select
  *,
  date(datehour) as date,
  mod(extract(dayofweek from datehour) + 5, 7) + 1 as day_of_week,
  extract(hour from datehour) as hour_of_day,
  case
    when regexp_contains(title, r'^(Вікіпедія|Файл|Спеціальна|Категорія|Портал):') then true
    else false
  end as is_meta_page,
  regexp_extract(title, r'^(Вікіпедія|Файл|Спеціальна|Категорія|Портал):') as meta_page_title
from unioned

