{{ config(materialized='table') }}

with base as (
    select
        order_id,
        date_trunc(order_purchase_timestamp, day) as order_date,
        (
          select sum(item.price + item.freight_value)
          from unnest(order_items) as item
        ) as order_revenue,
        order_status,
        customer_state
    from {{ ref('fp_sales_full') }}
),

aggregated as (
    select
        order_date,
        order_status,
        customer_state,
        count(distinct order_id) as total_orders,
        sum(order_revenue) as total_revenue
    from base
    group by 1, 2, 3
)

select *
from aggregated
