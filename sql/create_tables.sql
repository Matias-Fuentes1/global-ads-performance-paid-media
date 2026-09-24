-- Creación del Esquema en Estrella para Paid Media Analytics

-- Tablas de Dimensión
CREATE TABLE IF NOT EXISTS dim_platform (
    platform_id SERIAL PRIMARY KEY,
    platform_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_campaign_type (
    campaign_type_id SERIAL PRIMARY KEY,
    campaign_type_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_industry (
    industry_id SERIAL PRIMARY KEY,
    industry_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL
);

-- Tabla de Hechos (Fact Table)
CREATE TABLE IF NOT EXISTS fact_ads_performance (
    fact_id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    platform_id INT REFERENCES dim_platform(platform_id),
    campaign_type_id INT REFERENCES dim_campaign_type(campaign_type_id),
    industry_id INT REFERENCES dim_industry(industry_id),
    country_id INT REFERENCES dim_country(country_id),
    impressions INT,
    clicks INT,
    ctr NUMERIC(5, 4),
    cpc NUMERIC(10, 2),
    spend NUMERIC(10, 2),
    conversions INT,
    cpa NUMERIC(10, 2),
    revenue NUMERIC(12, 2),
    roas NUMERIC(10, 2)
);
