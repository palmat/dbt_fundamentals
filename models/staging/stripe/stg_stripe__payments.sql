select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    -- amount is stored in cents, conver to dollars
    cast(amount / 100 as numeric(10, 2)) as amount,
    created as created_at

from {{ source('stripe', 'payment') }}
