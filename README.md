# Global Ads Performance · Dashboard Unificado de Paid Media

## ¿De qué se trata?
Este es uno de mis proyectos de portfolio. Lo armé para practicar el modelado y análisis de datos de performance publicitaria a través de múltiples plataformas — un problema real de cualquier equipo de marketing que invierte en más de un canal y necesita comparar peras con peras.

La particularidad de este proyecto es el **modelado dimensional**: en vez de trabajar sobre la tabla plana original de Kaggle, diseñé un esquema estrella (`fact_ads_performance` + dimensiones de plataforma, país, industria, tipo de campaña y fecha) para que las métricas de eficiencia (ROAS, CPA, CTR, CPC) se calculen de forma consistente sin importar por qué dimensión se corte el análisis.

La pregunta que guió todo el análisis fue una sola: **¿qué canal de inversión publicitaria genera el mejor retorno?**

---

## Dataset
Descargado desde [Kaggle — Global Ads Performance: Google, Meta & TikTok](https://www.kaggle.com/datasets/nudratabbas/global-ads-performance-google-meta-tiktok). ~1.800 registros de campañas publicitarias en Google Ads, Meta Ads y TikTok Ads, con métricas de impresiones, clics, conversiones, costo y revenue por campaña.

| Dimensión | Qué representa |
|---|---|
| `platform` | Google Ads, Meta Ads o TikTok Ads |
| `campaign_type` | Tipo de campaña (Search, Video, Shopping, Display, etc.) |
| `country` | País de la campaña |
| `industry` | Rubro del anunciante |
| `date` | Fecha de la campaña |

---

## Qué hice con los datos antes de analizar
El dataset original era una tabla plana. Antes de tocar cualquier métrica:

* **Modelado dimensional:** transformé el archivo plano en un esquema estrella — una tabla de hechos (`fact_ads_performance`) con las métricas numéricas (clicks, conversions, spend, revenue, CTR, CPC, CPA, ROAS) conectada a 5 dimensiones (plataforma, país, industria, tipo de campaña, fecha).
* **Normalización con Python:** limpié y estructuré los datos con un script de ETL antes de cargarlos al modelo, asegurando tipos de dato consistentes y sin duplicados.
* **Definición de escala del proyecto:** con ~1.800 filas, decidí mantener el dashboard en una sola página bien densa en vez de forzar múltiples páginas con contenido diluido — cada visual tiene que responder algo concreto, no rellenar espacio.

---

## Lo que encontré

### El canal con más presupuesto no es el más eficiente
Google Ads concentra el **57% de la inversión total**, pero tiene el **CPA más alto de los tres canales** (48,43) y el **ROAS más bajo**. TikTok Ads, con solo el **19% del presupuesto**, tiene el **CPA más bajo** (21,67) y el **mejor ROAS** de las tres plataformas.

| Plataforma | % del Spend | CPA | ROAS |
|---|---|---|---|
| Google Ads | 57% | 48,43 | Más bajo |
| Meta Ads | 24% | 28,75 | Intermedio |
| TikTok Ads | 19% | 21,67 | Más alto |

### La eficiencia general es sólida: ROAS 4,88
Sobre una inversión total de **$22,22M**, el revenue generado fue de **$108,37M** — un ROAS global de **4,88**, con **654 mil conversiones** totales.

### El embudo muestra una caída fuerte de impresión a clic
De **371 millones de impresiones**, solo **14 millones** se convirtieron en clics (CTR del 3,85%), y de ahí a conversión la caída sigue siendo pronunciada. La mayor pérdida de volumen ocurre en el primer paso del embudo, no en los últimos.

---

## Qué haría con esta información
1. **Reasignar presupuesto desde Google Ads hacia TikTok Ads:** dado que TikTok muestra mejor ROAS y menor CPA con solo un tercio del presupuesto de Google, hay una oportunidad clara de mejorar la eficiencia global moviendo inversión hacia el canal que mejor retorna, en vez de seguir concentrando el gasto en el canal de peor desempeño relativo.
2. **Auditar la etapa de impresión a clic:** la mayor fuga de todo el embudo ocurre ahí — vale la pena revisar creatividades, segmentación de audiencia y relevancia del anuncio antes que cualquier otra optimización.
3. **Validar el hallazgo por tipo de campaña e industria:** antes de mover presupuesto a nivel global, cruzar el ROAS por plataforma con tipo de campaña e industria, para asegurarse de que el patrón se sostiene y no está impulsado por un solo segmento.

---

## El dashboard
Diseñado en una sola página, densa mediante los 1.800 registros disponibles, para responder la pregunta central sin diluir el contenido en páginas de relleno:

* **KPIs principales:** Spend, Costo por Clic, ROAS y Tasa de Clics, con variación respecto al período anterior.
* **Evolución mensual:** inversión, revenue y ROAS a lo largo del año.
* **Eficiencia por plataforma:** ROAS y CPA comparados entre Google, Meta y TikTok.
* **Embudo completo:** de impresión a conversión.
* **Segmentación por canal:** inversión y conversiones distribuidas por plataforma.

---

*Herramientas: Python (ETL/normalización) · SQL · Power BI (modelado dimensional, DAX)*
