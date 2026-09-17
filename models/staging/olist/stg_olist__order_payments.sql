-- One row per order_id + payment_sequential. An order can be paid through
-- more than one method (e.g. part voucher + part credit card), so this is
-- NOT one row per order — that collapse happens in int_order_payments_agg.

with source as (
    select * from {{ source('olist_raw', 'olist_order_payments_dataset') }}
)

select
    order_id,
    cast(payment_sequential as int64) as payment_sequential,
    payment_type,
    cast(payment_installments as int64) as payment_installments,
    cast(payment_value as numeric) as payment_value
from source
