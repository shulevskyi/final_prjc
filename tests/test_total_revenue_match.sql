{{ config(severity='error') }}

with 
full_revenue as (
    select 
      round(
        sum((
          select sum(item.price + item.freight_value)
          from unnest(order_items) as item
        )), 2
      ) as total_revenue
    from {{ ref('fp_sales_full') }}
),

mart_revenue as (
    select 
      round(sum(total_revenue), 2) as total_revenue
    from {{ ref('order_performance_analysis') }}
)

select *
from full_revenue, mart_revenue
where full_revenue.total_revenue != mart_revenue.total_revenue
