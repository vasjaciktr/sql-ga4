CREATE OR REPLACE TABLE `europafoodxb-450709.analytics_ecommerce.channel_daily`
PARTITION BY date AS

WITH purchases AS (

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS date,

  traffic_source.source AS source,
  traffic_source.medium AS medium,

  (SELECT value.string_value
   FROM UNNEST(event_params)
   WHERE key = 'transaction_id') AS transaction_id,

  COALESCE(
    (SELECT value.double_value FROM UNNEST(event_params) WHERE key='purchase_revenue'),
    (SELECT value.double_value FROM UNNEST(event_params) WHERE key='value'),
    0
  ) AS revenue

FROM `europafoodxb-450709.analytics_322286584.events_*`

WHERE event_name = 'purchase'

)

SELECT

date,

IFNULL(source, '(direct)') AS source,
IFNULL(medium, '(none)') AS medium,

COUNT(DISTINCT transaction_id) AS orders,
SUM(revenue) AS revenue,

SAFE_DIVIDE(SUM(revenue), COUNT(DISTINCT transaction_id)) AS aov

FROM purchases

GROUP BY date, source, medium
