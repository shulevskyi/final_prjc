with source as (

    select * from {{ source('fp_sources', 'fp_order_payments') }}

),

renamed as (

    select
        order_id,
        payment_sequential,
        lower(payment_type) as payment_type,
        payment_installments,
        payment_value

    from source

)

select * from renamed
