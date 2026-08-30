-- Q6: Late delivery by geography
-- Business question: are delays clustered in particular states?
-- Reproduces pandas result: national rate 4.8%, AL worst at 17.4%,
-- RJ high-volume outlier at 9.7% (states with 100+ orders only).

WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_state,
        (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) AS delay_days
    FROM raw.orders o
    JOIN raw.customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
),
bucketed AS (
    SELECT
        order_id,
        customer_state,
        (delay_days > 3) AS is_very_late
    FROM delivered_orders
),
state_summary AS (
    SELECT
        customer_state,
        COUNT(*) AS orders,
        COUNT(*) FILTER (WHERE is_very_late) AS late_orders
    FROM bucketed
    GROUP BY customer_state
)
SELECT
    customer_state,
    orders,
    late_orders,
    ROUND((100.0 * late_orders / orders)::numeric, 2) AS late_pct
FROM state_summary
WHERE orders >= 100
ORDER BY late_pct DESC
LIMIT 8;
