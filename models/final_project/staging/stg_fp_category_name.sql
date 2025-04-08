with source as (

    select * from {{ source('fp_sources', 'fp_category_name') }}

),

renamed as (

    select
        lower(string_field_0) as product_category_name,
        lower(string_field_1) as product_category_name_english

    from source

)

select * from renamed
