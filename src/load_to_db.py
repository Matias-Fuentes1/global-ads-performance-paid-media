import pandas as pd
from sqlalchemy import create_engine, text
import os
import urllib.parse


DB_USER = os.getenv("PAID_MEDIA_DB_USER", "postgres")
DB_PASSWORD = os.getenv("PAID_MEDIA_DB_PASSWORD")
DB_HOST = os.getenv("PAID_MEDIA_DB_HOST", "localhost")
DB_PORT = os.getenv("PAID_MEDIA_DB_PORT", "5432")
DB_NAME = os.getenv("PAID_MEDIA_DB_NAME", "paid_media_db")

if not DB_PASSWORD:
    raise RuntimeError("Set PAID_MEDIA_DB_PASSWORD before loading data into PostgreSQL.")

safe_password = urllib.parse.quote_plus(DB_PASSWORD)
DB_CONNECTION_URL = f"postgresql://{DB_USER}:{safe_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


def load_data_to_postgres():
    print("Leyendo el CSV procesado...")
    df = pd.read_csv("data/processed/master_paid_media_performance.csv")
    engine = create_engine(DB_CONNECTION_URL)

    with engine.begin() as connection:
        connection.execute(text("TRUNCATE fact_ads_performance RESTART IDENTITY"))

    print("Conectando a PostgreSQL y cargando dimensiones...")

    dimensions = {
        "dim_platform": ("platform_name", df["channel_name"]),
        "dim_campaign_type": ("campaign_type_name", df["campaign_type"]),
        "dim_industry": ("industry_name", df["industry"]),
        "dim_country": ("country_name", df["country"]),
    }

    for table, (column, values) in dimensions.items():
        current = pd.read_sql(f"SELECT {column} FROM {table}", engine)[column]
        new_values = pd.DataFrame({column: values.unique()})
        new_values = new_values[~new_values[column].isin(current)]
        if not new_values.empty:
            new_values.to_sql(table, engine, if_exists="append", index=False)

    platform = pd.read_sql("SELECT platform_id, platform_name FROM dim_platform", engine)
    campaign = pd.read_sql("SELECT campaign_type_id, campaign_type_name FROM dim_campaign_type", engine)
    industry = pd.read_sql("SELECT industry_id, industry_name FROM dim_industry", engine)
    country = pd.read_sql("SELECT country_id, country_name FROM dim_country", engine)

    df = df.merge(platform, left_on="channel_name", right_on="platform_name")
    df = df.merge(campaign, left_on="campaign_type", right_on="campaign_type_name")
    df = df.merge(industry, left_on="industry", right_on="industry_name")
    df = df.merge(country, left_on="country", right_on="country_name")

    fact = df[[
        "date", "platform_id", "campaign_type_id", "industry_id", "country_id",
        "impressions", "clicks", "CTR", "CPC", "spend", "conversions", "CPA",
        "conversion_value", "ROAS",
    ]].rename(columns={
        "CTR": "ctr", "CPC": "cpc", "CPA": "cpa",
        "conversion_value": "revenue", "ROAS": "roas",
    })

    fact.to_sql("fact_ads_performance", engine, if_exists="append", index=False)
    print(f"Carga completada: {len(fact)} filas")


if __name__ == "__main__":
    load_data_to_postgres()
