with source as (

    select * from {{ source('fp_sources', 'fp_orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,

        order_status = 'delivered' as is_delivered,
        timestamp_diff(order_delivered_customer_date, order_purchase_timestamp, day) as delivery_days

    from source

)

select * from renamed
