# Raw data

The 9 source CSVs are not committed to this repo (see root `.gitignore`) — they total
~124MB, which doesn't belong in git history for a portfolio project.

**To reproduce:** download the Brazilian E-Commerce Public Dataset by Olist from Kaggle
and place the files directly in this folder:

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Expected filenames (matches `02_python/src/load_data.py`):

- `olist_customers_dataset.csv`
- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `product_category_name_translation.csv`

Once the files are here, `python -m src.load_data` (from `02_python/`) will confirm all
9 load correctly before running the notebooks or the Postgres load.
