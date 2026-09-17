-- One row per product_id. Cleans up category (English translation, with an
-- explicit, readable fallback for anything not in the translation table)
-- and flags incomplete physical dimensions rather than guessing at them.

with products as (
    select * from {{ ref('stg_olist__products') }}
),

category_translation as (
    select * from {{ ref('stg_olist__category_translation') }}
),

orders as (
    select * from {{ ref('stg_olist__orders') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items') }}
),

-- Order volume per product. Matches the project's revenue convention
-- (delivered orders only) so it's comparable to lifetime_revenue on
-- dim_customers and to category_performance_monthly's order_count.
delivered_order_items as (
    select
        oi.product_id,
        oi.order_id
    from order_items oi
    inner join orders o
        on oi.order_id = o.order_id
    where o.order_status = 'delivered'
),

product_order_counts as (
    select
        product_id,
        count(distinct order_id) as order_count
    from delivered_order_items
    group by product_id
)

select
    p.product_id,

    p.product_category_name as category_name_raw,

    -- Category cleanup + English translation.
    -- Two distinct "bad" cases are kept visibly different rather than merged
    -- into one flat 'unmapped' bucket, which would silently combine revenue
    -- from different real categories under a single label:
    --   1. no category on record at all      -> 'Uncategorized'
    --   2. category present but not found in  -> title-cased version of the
    --      the translation table                 raw Portuguese name, so it
    --                                             stays distinguishable from
    --                                             every other untranslated
    --                                             category in downstream
    --                                             rollups
    coalesce(
        ct.product_category_name_english,
        case
            when p.product_category_name is null then 'Uncategorized'
            else initcap(replace(p.product_category_name, '_', ' '))
        end
    ) as category_name_english,

    case
        when p.product_category_name is null then 'no_category_on_record'
        when ct.product_category_name is null then 'missing_translation'
        else 'translated'
    end as category_translation_status,

    -- Physical dimensions: not imputed. A small number of products are
    -- missing all four fields in the raw data. Flag rather than fabricate.
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    (
        p.product_weight_g is not null
        and p.product_length_cm is not null
        and p.product_height_cm is not null
        and p.product_width_cm is not null
    ) as has_complete_dimensions,

    coalesce(poc.order_count, 0) as order_count

from products p
left join category_translation ct
    on p.product_category_name = ct.product_category_name
left join product_order_counts poc
    on p.product_id = poc.product_id
