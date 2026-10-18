with source as (

    select * from {{ source('sales','products') }}
),


renamed as (

    select
        sku,
        trim(product_name)                                      as product_name,
        initcap(trim(category))                                 as category,
        cast(replace(replace(unit_price, '.', ''), ',', '.') as numeric(18, 2)) as list_price,
        _loaded_at                        
    from source
)


select * from renamed