{{ config(materialized='table') }}

with exploded as (
    select
        fsf.order_id,
        date_trunc(fsf.order_purchase_timestamp, month) as order_month,
        
        -- CROSS JOIN or comma join to unnest the order_items array
        item.seller_id,
        item.price,
        item.freight_value

    from {{ ref('fp_sales_full') }} fsf
    cross join unnest(fsf.order_items) as item
),

seller_stats as (
    select
        order_month,
        seller_id,
        sum(price) as total_sales,
        sum(freight_value) as total_freight,
        count(distinct order_id) as total_orders
    from exploded
    group by 1,2
)

select *
from seller_stats
