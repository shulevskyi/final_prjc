{{ config(severity='error') }}

with
full_orders as (
    select count(distinct order_id) as total_orders
    from {{ ref('fp_sales_full') }}
    where order_status = 'delivered'
),

daily_orders as (
    select sum(total_orders) as sum_of_daily_orders
    from {{ ref('order_performance_analysis') }}
)

select 
  full_orders.total_orders,
  daily_orders.sum_of_daily_orders
from full_orders, daily_orders
where full_orders.total_orders != daily_orders.sum_of_daily_orders
