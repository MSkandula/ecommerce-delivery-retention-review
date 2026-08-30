-- Q5: Freight cost as % of item price, by category
-- Business question: which categories have freight eating the most into price?
-- Aggregate ratio corrected in Python EDA from a naive 22.6% (simple column-sum
-- ratio) to 16.6% (category-weighted). This SQL version reproduces the
-- category-weighted method directly.
-- Reproduces pandas result: electronics ~29.1%, christmas_supplies ~36.7%
-- (categories with 100+ items only, to avoid small-sample distortion).

WITH category_freight AS (
    SELECT
        ct.product_category_name_english,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight,
        COUNT(*) AS items
    FROM raw.order_items oi
    JOIN raw.products p
        ON oi.product_id = p.product_id
    LEFT JOIN raw.category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
)
SELECT
    product_category_name_english,
    items,
    ROUND(total_price::numeric, 2) AS total_price,
    ROUND((100.0 * total_freight / total_price)::numeric, 2) AS freight_pct_of_price
FROM category_freight
WHERE items >= 100
ORDER BY freight_pct_of_price DESC
LIMIT 8;
