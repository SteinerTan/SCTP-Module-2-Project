-- One row per customer_id as it appears in the raw orders data.
-- Note: customer_unique_id is what identifies the same real-world person
-- across repeat purchases; customer_id changes per order in the raw Olist data.

with source as (
    select * from {{ source('olist_raw', 'olist_customers_dataset') }}
)

select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from source
