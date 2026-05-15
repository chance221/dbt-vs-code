
with orders as (
    select *  
    from {{ ref('stg_jaffle_shop__orders')}}
),

payments as (
    select *
    from {{ ref('stg_stripe__payments')}}
),

sum_totals as (
  select
    orders.customer_id,
    sum(case when status = 'completed' then payments.amount end) as lifetime_value,
  from orders
  left join payments using (order_id)
  group by orders.customer_id
),

final as (
    select
        order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(sum_totals.lifetime_value, 0) as amount

    from orders

    left join sum_totals using (customer_id)

)

select * from final