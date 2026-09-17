-- Collapses potentially multiple payment rows per order into one row, so
-- fct_orders can join 1:1. Mirrors the pattern the old reviews aggregation
-- used before order_reviews was dropped from the project's file scope.

with payments as (
    select * from {{ ref('stg_olist__order_payments') }}
),

agg as (
    select
        order_id,
        sum(payment_value) as order_payment_total,
        count(*) as payment_method_count,
        max(payment_installments) as max_installments
    from payments
    group by order_id
),

-- "primary" payment method = whichever one carried the largest share of the
-- order's value; ties broken deterministically by payment_sequential.
ranked_payments as (
    select
        order_id,
        payment_type,
        row_number() over (
            partition by order_id
            order by payment_value desc, payment_sequential asc
        ) as rn
    from payments
),

primary_method as (
    select order_id, payment_type as primary_payment_type
    from ranked_payments
    where rn = 1
)

select
    a.order_id,
    a.order_payment_total,
    a.payment_method_count,
    a.max_installments,
    pm.primary_payment_type
from agg a
left join primary_method pm
    on a.order_id = pm.order_id
