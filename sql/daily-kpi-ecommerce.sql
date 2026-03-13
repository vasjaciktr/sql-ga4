CREATE OR REPLACE TABLE `xxxx-450709.analytics_ecommerce.daily_kpis`
PARTITION BY date AS
WITH base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    event_name,
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'transaction_id') AS transaction_id,
    (SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'purchase_revenue') AS purchase_revenue,
    (SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'value') AS value_param
  FROM `europafoodxb-450709.analytics_322286584.events_*`
),
daily_users AS (
  SELECT
    date,
    COUNT(DISTINCT user_pseudo_id) AS users
  FROM base
  GROUP BY date
),
daily_orders AS (
  SELECT
    date,
    COUNT(DISTINCT transaction_id) AS orders,
    SUM(COALESCE(purchase_revenue, value_param, 0)) AS revenue
  FROM base
  WHERE event_name = 'purchase'
  GROUP BY date
)
SELECT
  u.date,
  COALESCE(o.revenue, 0) AS revenue,
  COALESCE(o.orders, 0) AS orders,
  u.users,
  SAFE_DIVIDE(o.revenue, o.orders) AS aov,
  SAFE_DIVIDE(o.orders, u.users) AS conversion_rate
FROM daily_users u
LEFT JOIN daily_orders o
USING (date);
