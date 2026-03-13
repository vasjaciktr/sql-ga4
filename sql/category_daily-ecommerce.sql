CREATE OR REPLACE TABLE `europafoodxb-450709.analytics_ecommerce.category_daily`
PARTITION BY date AS
WITH purchases AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'transaction_id') AS transaction_id,
    items.item_category AS category,
    items.quantity AS qty,
    items.price AS price
  FROM `europafoodxb-450709.analytics_322286584.events_*`,
  UNNEST(items) AS items
  WHERE event_name = 'purchase'
)
SELECT
  date,
  category,
  SUM(qty) AS units_sold,
  SUM(qty * price) AS revenue,
  COUNT(DISTINCT transaction_id) AS orders,
  SAFE_DIVIDE(SUM(qty * price), COUNT(DISTINCT transaction_id)) AS aov
FROM purchases
GROUP BY date, category;
