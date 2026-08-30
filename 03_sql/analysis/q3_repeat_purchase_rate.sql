-- Q3: Repeat purchase rate
-- Business question: what share of customers order more than once?
-- Keyed on customer_unique_id, not customer_id (customer_id is generated
-- fresh per order and would show a false 0% repeat rate — per Excel finding).
-- Reproduces pandas result: 3.12% repeat rate (2,997 of 96,096 customers).

WITH orders_per_customer AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM raw.orders o
    JOIN raw.customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        (100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*))::numeric, 2
    ) AS repeat_rate_pct
FROM orders_per_customer;
