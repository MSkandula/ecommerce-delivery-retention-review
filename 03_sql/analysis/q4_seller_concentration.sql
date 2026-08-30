-- Q4: Seller revenue concentration
-- Business question: what share of revenue comes from the top 10% of sellers?
-- Reproduces pandas result: top 310 of 3,095 sellers (10%) = 67.6% of revenue.

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue,
        COUNT(DISTINCT order_id) AS orders
    FROM raw.order_items
    GROUP BY seller_id
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS revenue_rank,
        COUNT(*) OVER () AS total_sellers
    FROM seller_revenue
),
top_10pct AS (
    SELECT *
    FROM ranked
    -- CEIL rather than ROUND, so a fractional 10% always rounds up to at
    -- least the intended count rather than potentially excluding one seller
    WHERE revenue_rank <= CEIL(total_sellers * 0.10)
)
SELECT
    (SELECT total_sellers FROM ranked LIMIT 1) AS total_sellers,
    COUNT(*) AS top_10pct_seller_count,
    ROUND(SUM(revenue)::numeric, 2) AS top_10pct_revenue,
    ROUND(
        (100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM seller_revenue))::numeric, 2
    ) AS top_10pct_revenue_share_pct
FROM top_10pct;
