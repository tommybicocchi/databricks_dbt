{{
    config({
        "materialized" : "incremental",
        "file_format" : "delta",
        "incremental_strategy" : "append"
    })
}}

SELECT
    transactionID,
    customerID,
    franchiseID,
    product,
    quantity,
    unitPrice,
    totalPrice,
    paymentMethod,
    cardNumber,
    dateTime,
    CURRENT_TIMESTAMP AS dt_ingestion_timestamp
FROM {{ source( 'sales', 'sales_transactions' ) }}
{% if is_incremental() %}
  WHERE dateTime > (SELECT max(dt_ingestion_timestamp) from {{ this }})
{% endif %}