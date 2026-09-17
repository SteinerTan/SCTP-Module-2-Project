-- lifetime_order_count / lifetime_revenue satisfy the assignment brief's
-- explicit ask for a derived "how much a customer has spent over time"
-- column. Only delivered orders count toward lifetime revenue, matching the
-- project's revenue definition (price only, delivered orders only).

with customers as (
    select * from {{ ref('stg_olist__customers') }}
),

orders as (
    select * from {{ ref('stg_olist__orders') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items') }}
),

delivered_order_items as (
    select
        o.customer_id,
        o.order_id,
        o.order_purchase_ts,
        oi.price
    from orders o
    left join order_items oi
        on o.order_id = oi.order_id
    where o.order_status = 'delivered'
),

customer_agg as (
    select
        customer_id,
        count(distinct order_id) as lifetime_order_count,
        sum(price) as lifetime_revenue,
        min(order_purchase_ts) as first_order_ts,
        max(order_purchase_ts) as last_order_ts
    from delivered_order_items
    group by customer_id
)

select
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    coalesce(ca.lifetime_order_count, 0) as lifetime_order_count,
    coalesce(ca.lifetime_revenue, 0) as lifetime_revenue,
    ca.first_order_ts,
    ca.last_order_ts
from customers c
left join customer_agg ca
    on c.customer_id = ca.customer_id
