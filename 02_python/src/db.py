"""
db.py
Single place that knows how to connect to the ecommerce_review database.
Every other module imports get_engine() from here rather than building
its own connection string — avoids config drift across files.
"""

import os
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv

# .env lives at the project root, two levels up from this file (02_python/src/db.py)
env_path = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(env_path)

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

DB_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


def get_engine():
    return create_engine(DB_URL)


if __name__ == "__main__":
    # Quick manual check: python -m src.db
    engine = get_engine()
    with engine.connect() as conn:
        print(f"Connected to {DB_NAME} successfully.")