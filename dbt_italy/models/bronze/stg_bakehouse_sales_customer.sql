{{
    config({
        "materialized" : "incremental",
        "tags" : ["bronze", "sales"],
        "file_format" : "delta",
        "incremental_strategy" : "insert_overwrite"
    })
}}

SELECT
      customerID,
      first_name,
      last_name,
      email_address,
      phone_number,
      address,
      city,
      state,
      country,
      continent,
      postal_zip_code,
      gender,
      CURRENT_TIMESTAMP AS dt_ingestion_timestamp
FROM {{ source( 'sales', 'sales_customers' ) }}