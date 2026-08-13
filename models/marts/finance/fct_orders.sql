with orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

payments as (
    select * from {{ ref ('stg_stripe__payments') }}
),

order_payments as (
    select
        order_id,
        sum(amount) as amount,
        count(order_id) as transaction_count
    from payments
    where lower(status) = 'success'
    group by order_id
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        cast(coalesce(order_payments.amount, 0) as numeric(10, 2)) as amount,
        coalesce(order_payments.transaction_count, 0) as transaction_count

    from orders
    left join order_payments
        on orders.order_id = order_payments.order_id

)

select * from final
