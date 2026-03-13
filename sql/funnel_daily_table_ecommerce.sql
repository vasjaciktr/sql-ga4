CREATE OR REPLACE TABLE `xxxx-450709.analytics_ecommerce.funnel_daily`
PARTITION BY date AS
WITH daily AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    COUNTIF(event_name = 'view_item_list') AS view_item_list_events,
    COUNTIF(event_name = 'view_item') AS view_item_events,
    COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
    COUNTIF(event_name = 'begin_checkout') AS begin_checkout_events,
    COUNTIF(event_name = 'purchase') AS purchase_events,

    COUNT(DISTINCT IF(event_name = 'view_item_list', user_pseudo_id, NULL)) AS view_item_list_users,
    COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS view_item_users,
    COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS add_to_cart_users,
    COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) AS begin_checkout_users,
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchase_users
  FROM `europafoodxb-450709.analytics_322286584.events_*`
  GROUP BY date
)
SELECT
  date,

  view_item_list_events,
  view_item_events,
  add_to_cart_events,
  begin_checkout_events,
  purchase_events,

  view_item_list_users,
  view_item_users,
  add_to_cart_users,
  begin_checkout_users,
  purchase_users,

  SAFE_DIVIDE(view_item_users, view_item_list_users) AS list_to_item_rate,
  SAFE_DIVIDE(add_to_cart_users, view_item_users) AS item_to_cart_rate,
  SAFE_DIVIDE(begin_checkout_users, add_to_cart_users) AS cart_to_checkout_rate,
  SAFE_DIVIDE(purchase_users, begin_checkout_users) AS checkout_to_purchase_rate,

  SAFE_DIVIDE(purchase_users, view_item_users) AS item_to_purchase_rate
FROM daily;
