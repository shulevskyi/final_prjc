{{ config(materialized='table') }}

with exploded as (
    -- Flatten out each payment record
    select
        date_trunc(f.order_purchase_timestamp, month) as order_month,
        pay.payment_type,
        pay.payment_installments,
        pay.payment_value
    from {{ ref('fp_sales_full') }} f
    left join unnest(f.order_payments) as pay
),

aggregated as (
    select
        order_month,
        payment_type,
        payment_installments,
        count(*) as payment_count,
        sum(payment_value) as total_payment_value
    from exploded
    group by 1,2,3
)

select *
from aggregated
