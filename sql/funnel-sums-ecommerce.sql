CREATE OR REPLACE TABLE `europafoodxb-450709.analytics_ecommerce.funnel_steps` AS

SELECT
'Product View' AS step,
SUM(view_item_users) AS users
FROM `europafoodxb-450709.analytics_ecommerce.funnel_daily`

UNION ALL

SELECT
'Add to Cart',
SUM(add_to_cart_users)
FROM `europafoodxb-450709.analytics_ecommerce.funnel_daily`

UNION ALL

SELECT
'Checkout',
SUM(begin_checkout_users)
FROM `europafoodxb-450709.analytics_ecommerce.funnel_daily`

UNION ALL

SELECT
'Purchase',
SUM(purchase_users)
FROM `europafoodxb-450709.analytics_ecommerce.funnel_daily`
