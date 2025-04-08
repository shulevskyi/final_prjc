{{ config(materialized='table') }}

-- identify the first purchase date for each customer
with first_purchase as (
    select
        customer_id,
        min(order_purchase_timestamp) as first_purchase_ts
    from {{ ref('fp_sales_full') }}
    group by 1
),

tagged as (
    select
        fsf.order_id,
        fsf.customer_id,
        fsf.order_purchase_timestamp,
        case 
          when fsf.order_purchase_timestamp = fp.first_purchase_ts then 'new_customer'
          else 'returning_customer'
        end as customer_type,
        -- total revenue for each order
        (select sum(item.price) from unnest(fsf.order_items) as item) as order_revenue
    from {{ ref('fp_sales_full') }} fsf
    left join first_purchase fp
        on fsf.customer_id = fp.customer_id
),

aggregated as (
    select
        date_trunc(order_purchase_timestamp, month) as order_month,
        customer_type,
        count(distinct order_id) as total_orders,
        sum(order_revenue) as total_revenue
    from tagged
    group by 1,2
)

select *
from aggregated
