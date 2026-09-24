-- ==========================================================
-- PAID MEDIA ANALYTICS - CONSULTAS ANALÍTICAS (ds.sql)
-- ==========================================================

-- 1. Rendimiento Global y Eficiencia por Plataforma (Google, Meta, TikTok)
-- Mide qué canal gasta más y cuál devuelve mejor ROAS y CTR.
SELECT 
    p.platform_name,
    SUM(f.spend) AS total_spend,
    SUM(f.impressions) AS total_impressions,
    SUM(f.clicks) AS total_clicks,
    ROUND(SUM(f.clicks)::numeric / NULLIF(SUM(f.impressions), 0) * 100, 2) AS global_ctr,
    ROUND(SUM(f.spend)::numeric / NULLIF(SUM(f.clicks), 0), 2) AS avg_cpc,
    ROUND(SUM(f.revenue)::numeric / NULLIF(SUM(f.spend), 0), 2) AS global_roas
FROM fact_ads_performance f
JOIN dim_platform p ON f.platform_id = p.platform_id
GROUP BY p.platform_name
ORDER BY global_roas DESC;


-- 2. Rendimiento por Tipo de Campaña (Conversiones y Costo por Adquisición)
-- Identifica qué formato o objetivo de campaña convierte mejor y de forma más barata.
SELECT 
    ct.campaign_type_name,
    SUM(f.spend) AS total_spend,
    SUM(f.conversions) AS total_conversions,
    ROUND(SUM(f.spend)::numeric / NULLIF(SUM(f.conversions), 0), 2) AS avg_cpa,
    ROUND(SUM(f.revenue)::numeric / NULLIF(SUM(f.spend), 0), 2) AS avg_roas
FROM fact_ads_performance f
JOIN dim_campaign_type ct ON f.campaign_type_id = ct.campaign_type_id
GROUP BY ct.campaign_type_name
ORDER BY total_conversions DESC;


-- 3. Rendimiento Geográfico (Top Países por Revenue y Retorno)
-- Evalúa en qué mercado rinde más el presupuesto publicitario.
SELECT 
    c.country_name,
    SUM(f.spend) AS total_spend,
    SUM(f.revenue) AS total_revenue,
    ROUND(SUM(f.revenue)::numeric / NULLIF(SUM(f.spend), 0), 2) AS country_roas
FROM fact_ads_performance f
JOIN dim_country c ON f.country_id = c.country_id
GROUP BY c.country_name
ORDER BY total_revenue DESC;


-- 4. Evolución Temporal (Tendencia Mensual de Inversión y Retorno)
-- Permite analizar el comportamiento del presupuesto y las ganancias mes a mes.
SELECT 
    TO_CHAR(f.date, 'YYYY-MM') AS year_month,
    SUM(f.spend) AS monthly_spend,
    SUM(f.revenue) AS monthly_revenue,
    ROUND(SUM(f.revenue)::numeric / NULLIF(SUM(f.spend), 0), 2) AS monthly_roas
FROM fact_ads_performance f
GROUP BY TO_CHAR(f.date, 'YYYY-MM')
ORDER BY year_month ASC;

import pandas as pd

# Cargá tu archivo (cambiá la ruta o nombre según corresponda)
df = pd.read_csv("tu_dataset.csv")

# 1. Ver tamaño y columnas
print("Dimensiones del dataset:", df.shape)
print("\nColumnas disponibles:", df.columns.tolist())

# 2. Ver cuántas campañas, plataformas y países hay realmente
print("\n--- Conteo de categorías ---")
print("Campañas únicas:", df["campaign_name"].nunique() if "campaign_name" in df.columns else "No está la columna")
print("Plataformas:", df["platform_name"].unique() if "platform_name" in df.columns else "N/A")
print("Países:", df["country_name"].unique() if "country_name" in df.columns else "N/A")

# 3. Agrupado rápido por campaña para ver qué tan parejo o desparejo es
if "campaign_name" in df.columns and "spend" in df.columns:
    print("\n--- Resumen por Campaña ---")
    resumen = df.groupby("campaign_name").agg({
        "spend": "sum",
        "revenue": "sum"
    })
    resumen["ROAS"] = resumen["revenue"] / resumen["spend"]
    print(resumen)

# Agrupamos por campaña y ordenamos de mayor a menor gasto
pareto_campañas = df.groupby("campaign_name").agg({
    "spend": "sum",
    "revenue": "sum"
}).sort_values(by="spend", ascending=False).reset_index()

# Calculamos el porcentaje acumulado del gasto
pareto_campañas["spend_cum_pct"] = (pareto_campañas["spend"].cumsum() / pareto_campañas["spend"].sum()) * 100
pareto_campañas["roas"] = pareto_campañas["revenue"] / pareto_campañas["spend"]

print("--- Análisis de Pareto por Campaña ---")
print(pareto_campañas.head(10))