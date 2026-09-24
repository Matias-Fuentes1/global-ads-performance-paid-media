import pandas as pd


def process_global_ads_data(input_path, output_path):
  df = pd.read_csv(input_path)
  df = df.rename(
      columns={
          "platform": "channel_name",
          "ad_spend": "spend",
          "revenue": "conversion_value",
      }
  )

  df["date"] = pd.to_datetime(df["date"], errors="coerce")
  for column in ["impressions", "clicks", "conversions"]:
    df[column] = pd.to_numeric(df[column], errors="coerce").fillna(0)
  for column in ["spend", "conversion_value"]:
    df[column] = pd.to_numeric(df[column], errors="coerce").fillna(0.0)

  df["CTR"] = df["clicks"] / df["impressions"].replace(0, 1) * 100
  df["CPC"] = df["spend"] / df["clicks"].replace(0, 1)
  df["CPA"] = df["spend"] / df["conversions"].replace(0, 1)
  df["ROAS"] = df["conversion_value"] / df["spend"].replace(0, 1)
  df["date"] = pd.to_datetime(df["date"])

  print("Min date:", df["date"].min())
  print("Max date:", df["date"].max())
  print("Unique dates:", df["date"].nunique())
  print("Rows:", len(df))

  df.to_csv(output_path, index=False)
  print(f"ETL completado: {len(df)} filas guardadas en {output_path}")
  return df


if __name__ == "__main__":
  process_global_ads_data(
      "data/raw/global_ads_performance_dataset.csv",
      "data/processed/master_paid_media_performance.csv",
  )