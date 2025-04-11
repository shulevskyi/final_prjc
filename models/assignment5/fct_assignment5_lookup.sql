{{ config(
    materialized = 'incremental',
    unique_key = 'title'
) }}

WITH source_data AS (

    SELECT
        title,
        DATE(datehour) AS date,  -- define the alias here
        views
    FROM {{ source('test_dataset', 'assignment5_input') }}
    
    {% if is_incremental() %}
    WHERE DATE(datehour) >= (
        SELECT MAX(max_date) FROM {{ this }}  -- ✅ use max_date here, NOT date
    ) - 1
    {% endif %}

),

aggregated AS (

    SELECT
        title,
        MIN(date) AS min_date,
        MAX(date) AS max_date,
        SUM(views) AS total_views
    FROM source_data
    GROUP BY title

)

SELECT * FROM aggregated
