with source as (
    select * from {{ source('olist_raw', 'product_category_name_translation') }}
)

select
    nullif(trim(product_category_name), '') as product_category_name,
    trim(product_category_name_english) as product_category_name_english
from source