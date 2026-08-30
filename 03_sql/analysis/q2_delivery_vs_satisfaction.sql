-- Q2: Delivery delay vs. review score
-- Business question: does late delivery actually lower satisfaction, and by how much?
-- Headline finding of the project. Reproduces the pandas result from
-- 02_eda_findings.ipynb (4.29 early -> 1.85 for 4+ days late).
--
-- Decisions carried forward:
-- - scoped to delivered orders only (order_status = 'delivered'), per decisions_log.md
-- - reviews deduplicated on order_id, keeping one row per order (review_id not
--   reliable as a unique key, per profiling finding)

WITH delivered_orders AS (
    SELECT
        order_id,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        (order_delivered_customer_date::date - order_estimated_delivery_date::date) AS delay_days
    FROM raw.orders
    WHERE order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND order_estimated_delivery_date IS NOT NULL
),
bucketed AS (
    SELECT
        order_id,
        delay_days,
        CASE
            WHEN delay_days <= -1 THEN 'early'
            WHEN delay_days = 0 THEN 'on_time'
            WHEN delay_days BETWEEN 1 AND 3 THEN '1-3 days late'
            ELSE '4+ days late'
        END AS delivery_bucket
    FROM delivered_orders
),
reviews_dedup AS (
    -- one row per order_id, arbitrary tie-break via MIN(review_id) — matches
    -- pandas' drop_duplicates(keep="first") in intent, not necessarily row-for-row,
    -- since neither method has a defined "first" without an explicit sort key
    SELECT DISTINCT ON (order_id)
        order_id,
        review_score
    FROM raw.reviews
    ORDER BY order_id, review_id
)
SELECT
    b.delivery_bucket,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders
FROM bucketed b
JOIN reviews_dedup r
    ON b.order_id = r.order_id
GROUP BY b.delivery_bucket
ORDER BY
    CASE b.delivery_bucket
        WHEN 'early' THEN 1
        WHEN 'on_time' THEN 2
        WHEN '1-3 days late' THEN 3
        WHEN '4+ days late' THEN 4
    END;
