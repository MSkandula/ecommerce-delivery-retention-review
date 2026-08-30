-- Confirms every raw table's row count in Postgres matches
-- what was found in Excel and reproduced in Python profiling.
-- Fourth independent cross-check across three tools.

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM raw.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM raw.payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM raw.reviews
UNION ALL
SELECT 'products', COUNT(*) FROM raw.products
UNION ALL
SELECT 'sellers', COUNT(*) FROM raw.sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM raw.geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM raw.category_translation
ORDER BY table_name;
