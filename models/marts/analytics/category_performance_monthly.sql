-- The direct input to Member 4's ABC/revenue-tiering analysis.
-- Bakes in the project's agreed definitions so the numbers in the exec deck
-- trace back to exactly one place:
--   - delivered orders only
--   - revenue = price only (freight excluded, tracked separately)
--   - analysis window: Jan 2017 - Aug 2018 (2016 excluded as ramp-up noise)
--
-- NOTE: the "Quality signal" leg of the team's decision matrix (average
-- review_score per category, below-median = weak) has NO data source in
-- this table anymore. The project scope was narrowed to the 6 core files,
-- which excludes order_reviews, so this table only carries revenue/trend
-- inputs and the freight-ratio logistics proxy. The Tier C discount/
-- discontinue conditions in the Refined Problem Statement doc reference
-- reviews explicitly — the team needs to either drop that condition or
-- re-add order_reviews before Member 4 applies the decision matrix.

with order_items as (
    select * from {{ ref('fct_order_items') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

joined as (
    select
        oi.category_name_english,
        date_trunc(o.order_purchase_ts, month) as order_month,
        oi.order_id,
        oi.price,
        oi.freight_value
    from order_items oi
    inner join orders o
        on oi.order_id = o.order_id
    where o.order_status = 'delivered'
        and o.order_purchase_ts >= timestamp('2017-01-01')
        and o.order_purchase_ts < timestamp('2018-09-01')
)

select
    category_name_english,
    order_month,
    sum(price) as revenue,
    count(distinct order_id) as order_count,
    safe_divide(sum(freight_value), sum(price)) as avg_freight_price_ratio
from joined
group by category_name_english, order_month
