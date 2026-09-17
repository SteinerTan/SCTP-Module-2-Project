-- One row per order. order_status is untouched (not pre-filtered) so any
-- downstream query chooses its own filter deliberately. order_revenue is the
-- brief's "total sale amount" derived column, rolled up from order items.
-- order_payment_total is the equivalent rollup from order_payments — kept
-- alongside order_total_paid (items) as a built-in sanity check: the two
-- should be close for delivered orders, and a large gap flags a join/filter
-- bug (see Working Guide step 11).

with orders as (
    select * from {{ ref('stg_olist__orders') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items') }}
),

payments as (
    select * from {{ ref('int_order_payments_agg') }}
),

order_totals as (
    select
        order_id,
        sum(price) as order_revenue,
        sum(freight_value) as order_freight,
        count(*) as item_count
    from order_items
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_ts,
    o.order_delivered_customer_ts,
    o.order_estimated_delivery_ts,
    coalesce(ot.order_revenue, 0) as order_revenue,
    coalesce(ot.order_freight, 0) as order_freight,
    coalesce(ot.order_revenue, 0) + coalesce(ot.order_freight, 0) as order_total_paid,
    coalesce(ot.item_count, 0) as item_count,
    p.order_payment_total,
    p.payment_method_count,
    p.max_installments,
    p.primary_payment_type
from orders o
left join order_totals ot
    on o.order_id = ot.order_id
left join payments p
    on o.order_id = p.order_id
