-- One row per order. order_status is kept exactly as-is here on purpose —
-- the "delivered only" filter is applied deliberately downstream, not baked
-- in silently at this layer.

with source as (
    select * from {{ source('olist_raw', 'olist_orders_dataset') }}
)

select
    order_id,
    customer_id,
    order_status,
    safe_cast(order_purchase_timestamp as timestamp) as order_purchase_ts,
    safe_cast(order_approved_at as timestamp) as order_approved_ts,
    safe_cast(order_delivered_carrier_date as timestamp) as order_delivered_carrier_ts,
    safe_cast(order_delivered_customer_date as timestamp) as order_delivered_customer_ts,
    safe_cast(order_estimated_delivery_date as timestamp) as order_estimated_delivery_ts
from source
