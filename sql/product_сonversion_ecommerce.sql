CREATE OR REPLACE TABLE `xxxx-450709.analytics_ecommerce.product_conversion_daily`
PARTITION BY date AS

WITH item_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    event_name,
    user_pseudo_id,
    items.item_name AS product,
    items.item_category AS category
  FROM `europafoodxb-450709.analytics_322286584.events_*`,
  UNNEST(items) AS items
  WHERE event_name IN ('view_item', 'add_to_cart')
),

purchases AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    user_pseudo_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'transaction_id') AS transaction_id,
    items.item_name AS product,
    items.item_category AS category,
    items.quantity AS qty,
    items.price AS price
  FROM `europafoodxb-450709.analytics_322286584.events_*`,
  UNNEST(items) AS items
  WHERE event_name = 'purchase'
),

daily_item_metrics AS (
  SELECT
    date,
    product,
    category,

    COUNTIF(event_name = 'view_item') AS view_item_events,
    COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,

    COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS view_item_users,
    COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS add_to_cart_users

  FROM item_events
  GROUP BY date, product, category
),

daily_purchase_metrics AS (
  SELECT
    date,
    product,
    category,

    COUNT(DISTINCT transaction_id) AS purchase_orders,
    COUNT(DISTINCT user_pseudo_id) AS purchase_users,
    SUM(qty) AS units_sold,
    SUM(qty * price) AS revenue

  FROM purchases
  GROUP BY date, product, category
)

SELECT
  COALESCE(i.date, p.date) AS date,
  COALESCE(i.product, p.product) AS product,
  COALESCE(i.category, p.category) AS category,

  COALESCE(i.view_item_events, 0) AS view_item_events,
  COALESCE(i.add_to_cart_events, 0) AS add_to_cart_events,
  COALESCE(i.view_item_users, 0) AS view_item_users,
  COALESCE(i.add_to_cart_users, 0) AS add_to_cart_users,

  COALESCE(p.purchase_orders, 0) AS purchase_orders,
  COALESCE(p.purchase_users, 0) AS purchase_users,
  COALESCE(p.units_sold, 0) AS units_sold,
  COALESCE(p.revenue, 0) AS revenue,

  SAFE_DIVIDE(COALESCE(i.add_to_cart_users, 0), NULLIF(COALESCE(i.view_item_users, 0), 0)) AS item_to_cart_rate,
  SAFE_DIVIDE(COALESCE(p.purchase_users, 0), NULLIF(COALESCE(i.view_item_users, 0), 0)) AS item_to_purchase_rate,
  SAFE_DIVIDE(COALESCE(p.purchase_orders, 0), NULLIF(COALESCE(i.add_to_cart_users, 0), 0)) AS cart_to_purchase_rate

FROM daily_item_metrics i
FULL OUTER JOIN daily_purchase_metrics p
USING (date, product, category);
