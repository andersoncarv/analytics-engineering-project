with source as (

    select * from {{ source('sales', 'customers') }}

),

renamed as (

    select
        id                        as customer_id,
        trim(name)                as customer_name,
        lower(trim(email))        as email,
        trim(city)                as city,
        upper(trim(state))        as state,
        cast(created_at as date)  as customer_created_at,
        _loaded_at
    from source

)

select * from renamed