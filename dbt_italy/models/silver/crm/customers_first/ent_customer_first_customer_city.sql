{{
    config({
        "materialized" : "incremental",
        "tags" : ["silver", "crm"],
        "file_format" : "delta",
        "unique_key" : "cd_customer_code",
        "incremental_strategy" : "merge"
    })
}}

WITH bronze_layer_data_to_be_format
AS (
    SELECT
        customer_id AS cd_customer_code,
        customer_name AS gn_customer_name,
        city AS gn_city_name,
        last_updated AS dt_last_updated_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY last_updated DESC
        ) AS nm_priority_over_city_info_number,
        CURRENT_TIMESTAMP AS dt_ingestion_timestamp
    FROM {{ ref('stg_customer_first_customers_city') }}
)
SELECT
    cd_customer_code,
    gn_customer_name,
    gn_city_name,
    dt_last_updated_timestamp,
    dt_ingestion_timestamp
FROM bronze_layer_data_to_be_format
WHERE nm_priority_over_city_info_number = 1