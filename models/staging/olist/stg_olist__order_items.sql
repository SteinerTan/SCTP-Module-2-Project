-- One row per order line item. price and freight_value are kept as separate
-- columns on purpose — the project's revenue definition is price only.

with source as (
    select * from {{ source('olist_raw', 'olist_order_items_dataset') }}
)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    safe_cast(shipping_limit_date as timestamp) as shipping_limit_ts,
    cast(price as numeric) as price,
    cast(freight_value as numeric) as freight_value
from source
