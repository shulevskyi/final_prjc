{{ config(
    materialized='table',
    partition_by={
        "field": "order_purchase_timestamp",
        "data_type": "timestamp"
    },
    cluster_by=["order_status", "customer_id"],
    partitions={
        "require_partition_filter": false,
        "field": "order_purchase_timestamp",
        "data_type": "timestamp"
    }
) }}

with orders as (
    select * from {{ ref('stg_fp_orders') }}
),

customers as (
    select * from {{ ref('stg_fp_customers') }}
),

/* 
  1) We join stg_fp_order_items to stg_fp_products 
  2) Then we join to stg_fp_category_name
  3) Finally, we GROUP BY order_id to create a single array of items per order 
*/
items as (
    select
        oi.order_id,
        array_agg(
            struct(
                oi.order_item_id as order_item_id,
                oi.product_id as product_id,
                p.product_category_name as product_category_name,
                c.product_category_name_english as product_category_name_english,
                oi.seller_id as seller_id,
                oi.price as price,
                oi.freight_value as freight_value
            )
        ) as order_items
    from {{ ref('stg_fp_order_items') }} as oi
    left join {{ ref('stg_fp_products') }} as p 
        on oi.product_id = p.product_id
    left join {{ ref('stg_fp_category_name') }} as c
        on lower(p.product_category_name) = lower(c.product_category_name)
    group by oi.order_id
),

/*
  1) We group payments by order_id
  2) Then store all payment methods for an order in one array
*/
payments as (
    select
        op.order_id,
        array_agg(
            struct(
                op.payment_sequential,
                op.payment_type,
                op.payment_installments,
                op.payment_value
            )
        ) as order_payments
    from {{ ref('stg_fp_order_payments') }} as op
    group by op.order_id
),

joined as (
    select
        o.order_id,
        o.customer_id,
        -- from stg_fp_customers
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        
        -- order info
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        o.is_delivered,
        o.delivery_days,
        
        -- arrays
        i.order_items,
        p.order_payments

    from orders o
    left join customers c 
        on o.customer_id = c.customer_id
    left join items i 
        on o.order_id = i.order_id
    left join payments p
        on o.order_id = p.order_id
)

select
    *
from joined
