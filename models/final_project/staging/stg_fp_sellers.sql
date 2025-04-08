with source as (

    select * from {{ source('fp_sources', 'fp_sellers') }}

),

renamed as (

    select
        seller_id,
        cast(seller_zip_code_prefix as string) as seller_zip_code_prefix,
        lower(seller_city) as seller_city,
        seller_state

    from source

)

select * from renamed
