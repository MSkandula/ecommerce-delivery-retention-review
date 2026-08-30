"""
load_data.py
Shared loading utility for the Olist e-commerce dataset.
Keeps loading logic in one place so both notebooks (profiling, EDA)
read data identically — avoids two versions of "the truth" drifting apart.
"""

import pandas as pd
from pathlib import Path

# Path is relative to the project root, not the notebook's own folder,
# so this works the same whether it's imported from 02_python/notebooks/ or run standalone.
RAW_DATA_DIR = Path(__file__).resolve().parents[2] / "data" / "raw"

TABLE_FILES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def load_all_tables(data_dir: Path = RAW_DATA_DIR) -> dict[str, pd.DataFrame]:
    """
    Loads all 9 Olist CSVs into a dict of DataFrames, keyed by short table name.
    Raises a clear error early if a file is missing, rather than failing
    later inside an analysis cell with a confusing traceback.
    """
    tables = {}
    missing = []

    for name, filename in TABLE_FILES.items():
        filepath = data_dir / filename
        if not filepath.exists():
            missing.append(filename)
            continue
        tables[name] = pd.read_csv(filepath)

    if missing:
        raise FileNotFoundError(
            f"Missing {len(missing)} expected file(s) in {data_dir}: {missing}"
        )

    return tables


if __name__ == "__main__":
    # Quick manual check when run directly: python -m src.load_data
    tables = load_all_tables()
    for name, df in tables.items():
        print(f"{name:22s} {df.shape[0]:>8,} rows  x  {df.shape[1]} cols")