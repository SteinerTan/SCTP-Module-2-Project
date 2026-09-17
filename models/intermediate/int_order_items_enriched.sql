-- Attaches the English category name to each order item, using the same
-- category-fallback logic as dim_products (duplicated here rather than
-- re-referenced, since this is an intermediate model and dim_products is
-- a mart — keeping the dependency direction staging -> intermediate -> marts
-- one-way). If you change the fallback rule in one place, change it here too.

with order_items as (
    select * from {{ ref('stg_olist__order_items') }}
),

products as (
    select * from {{ ref('stg_olist__products') }}
),

category_translation as (
    select * from {{ ref('stg_olist__category_translation') }}
)

select
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    coalesce(
        ct.product_category_name_english,
        case
            when p.product_category_name is null then 'Uncategorized'
            else initcap(replace(p.product_category_name, '_', ' '))
        end
    ) as category_name_english
from order_items oi
left join products p
    on oi.product_id = p.product_id
left join category_translation ct
    on p.product_category_name = ct.product_category_name