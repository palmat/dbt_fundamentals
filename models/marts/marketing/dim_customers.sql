with customers as (

    select * from {{ ref('stg__jaffle_shop__customers') }}

),

orders as (

    select * from {{ ref('stg__jaffle_shop__orders') }}

),

payments as (
    select * from {{ ref("stg_stripe__payments") }}
    where lower(status) = 'success'
),

customer_orders as (

    select
        o.customer_id,
        min(o.order_date) as first_order_date,
        max(o.order_date) as most_recent_order_date,
        count(o.order_id) as number_of_orders,
        sum(p.amount) as lifetime_value

    from orders o
    left join payments p on o.order_id = p.order_id

    group by o.customer_id

),


final as (

    select
        c.customer_id,
        c.first_name,
        c.last_name,
        co.first_order_date,
        co.most_recent_order_date,
        coalesce(co.number_of_orders, 0) as number_of_orders,
        cast(coalesce(co.lifetime_value, 0) as numeric(10, 2)) as lifetime_value

    from customers c
    left join customer_orders co
        on c.customer_id = co.customer_id

)

select * from final
