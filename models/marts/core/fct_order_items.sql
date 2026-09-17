-- One row per order line item (grain: order_id + order_item_id).
-- price and freight_value stay as separate columns — revenue = price only.

with enriched as (
    select * from {{ ref('int_order_items_enriched') }}
)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    category_name_english,
    price,
    freight_value
from enriched
