{{ config(materialized='table') }}

with exploded as (
    select
        fsf.order_id,
        fsf.order_purchase_timestamp,
        fsf.customer_state,
        item.product_id,
        item.price
    from {{ ref('fp_sales_full') }} fsf
    left join unnest(fsf.order_items) as item
),

aggregated as (
    select
        date_trunc(order_purchase_timestamp, month) as month,
        customer_state,
        product_id,
        count(distinct order_id) as order_count,
        sum(price) as total_sales
    from exploded
    group by 1,2,3
),

ranked as (
    select
        month,
        customer_state,
        product_id,
        order_count,
        total_sales,
        row_number() over(
            partition by month, customer_state
            order by total_sales desc
        ) as product_rank
    from aggregated
)

select *
from ranked
