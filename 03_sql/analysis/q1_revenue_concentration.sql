-- Q1: Revenue concentration by category
-- Business question: which categories drive revenue vs. volume?
-- Reproduces the pandas result from 02_eda_findings.ipynb (top 10 of 71
-- categories = 63.2% of revenue) as an independent SQL confirmation.

WITH category_revenue AS (
    SELECT
        ct.product_category_name_english,
        SUM(oi.price) AS revenue,
        COUNT(DISTINCT oi.order_id) AS orders
    FROM raw.order_items oi
    JOIN raw.products p
        ON oi.product_id = p.product_id
    LEFT JOIN raw.category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
),
ranked AS (
    SELECT
        *,
        ROUND((100.0 * revenue / SUM(revenue) OVER ())::numeric, 2) AS revenue_pct,
        ROUND((100.0 * SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER ())::numeric, 2) AS cumulative_pct
    FROM category_revenue
)
SELECT *
FROM ranked
ORDER BY revenue DESC
LIMIT 10;
