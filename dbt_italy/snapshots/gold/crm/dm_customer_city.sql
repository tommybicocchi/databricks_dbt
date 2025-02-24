SELECT
    sk_cd_customer_code_gn_city_name,
    cd_customer_code,
    gn_customer_name,
    gn_city_name,
    dt_last_updated_timestamp,
    dt_updated_at_timestamp,
    dt_valid_from_timestamp,
    dt_valid_to_timestamp,
    fl_is_deleted_flag,
    dt_ingestion_timestamp
FROM {{ ref('ent_customer_first_customer_city') }}