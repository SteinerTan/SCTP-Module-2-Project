-- One row per product. product_category_name is still in Portuguese here —
-- the English translation is joined on in the marts layer, not here, so
-- this model stays a near-1:1 passthrough of the raw table.
-- Only light cleanup at this layer: trim whitespace and turn a blank string
-- into a true NULL, so downstream models can tell "no category on record"
-- apart from "category present but not found in the translation table".

with source as (
    select * from {{ source('olist_raw', 'olist_products_dataset') }}
)

select
    product_id,
    nullif(trim(product_category_name), '') as product_category_name,
    safe_cast(product_weight_g as numeric) as product_weight_g,
    safe_cast(product_length_cm as numeric) as product_length_cm,
    safe_cast(product_height_cm as numeric) as product_height_cm,
    safe_cast(product_width_cm as numeric) as product_width_cm
from source