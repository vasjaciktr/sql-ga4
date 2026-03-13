CREATE OR REPLACE TABLE `europafoodxb-450709.analytics_ecommerce.customer_daily`
PARTITION BY date AS
WITH purchases AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'transaction_id') AS transaction_id,
    COALESCE(
      (SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'purchase_revenue'),
      (SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'value'),
      0
    ) AS revenue,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number') AS ga_session_number
  FROM `europafoodxb-450709.analytics_322286584.events_*`
  WHERE event_name = 'purchase'
),
buyer_lifetime AS (
  SELECT
    user_pseudo_id,
    COUNT(DISTINCT transaction_id) AS lifetime_orders
  FROM purchases
  GROUP BY user_pseudo_id
)
SELECT
  p.date,
  COUNT(DISTINCT p.user_pseudo_id) AS buyers,
  COUNT(DISTINCT IF(p.ga_session_number = 1, p.user_pseudo_id, NULL)) AS new_buyers,
  COUNT(DISTINCT IF(p.ga_session_number > 1, p.user_pseudo_id, NULL)) AS returning_buyers,
  COUNT(DISTINCT IF(bl.lifetime_orders >= 2, p.user_pseudo_id, NULL)) AS repeat_buyers,
  SUM(p.revenue) AS revenue
FROM purchases p
LEFT JOIN buyer_lifetime bl
USING (user_pseudo_id)
GROUP BY p.date;
