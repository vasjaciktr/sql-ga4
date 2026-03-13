-- GA4 Core Metrics in BigQuery
-- Example queries for common GA4 KPIs using raw export tables

-- Replace with your project and dataset
-- `project.dataset.events_*`

--------------------------------------------------
-- Users
--------------------------------------------------
SELECT
  COUNT(DISTINCT user_pseudo_id) AS users
FROM `project.dataset.events_*`;

--------------------------------------------------
-- Sessions
--------------------------------------------------
SELECT
  COUNT(DISTINCT CONCAT(user_pseudo_id, ga_session_id)) AS sessions
FROM `project.dataset.events_*`;

--------------------------------------------------
-- Engaged Sessions
--------------------------------------------------
SELECT
  COUNT(DISTINCT IF(engagement_time_msec > 0,
    CONCAT(user_pseudo_id, ga_session_id),
    NULL
  )) AS engaged_sessions
FROM `project.dataset.events_*`;

--------------------------------------------------
-- Pageviews
--------------------------------------------------
SELECT
  COUNTIF(event_name = 'page_view') AS pageviews
FROM `project.dataset.events_*`;

--------------------------------------------------
-- Total Revenue
--------------------------------------------------
SELECT
  SUM(ecommerce.purchase_revenue) AS revenue
FROM `project.dataset.events_*`;

--------------------------------------------------
-- Revenue
--------------------------------------------------
SELECT value.double_value
FROM UNNEST(event_params)
WHERE key='value' AS revenue
  
--------------------------------------------------
-- Transaction ID
--------------------------------------------------
SELECT
  value.string_value AS transaction_id
FROM `project.dataset.events_*`,
UNNEST(event_params)
WHERE key = 'transaction_id';

--------------------------------------------------
-- Page Location
--------------------------------------------------
SELECT
  value.string_value AS page_location
FROM `project.dataset.events_*`,
UNNEST(event_params)
WHERE key = 'page_location';

--------------------------------------------------
-- New Users (Returning Users WHEN ELSE)
--------------------------------------------------
SELECT 
  value.int_value 
FROM UNNEST(event_params)
WHERE key='ga_session_number') = 1

--------------------------------------------------
-- Unique Buyers
--------------------------------------------------
COUNT(DISTINCT IF(event_name='purchase', user_pseudo_id, NULL))

--------------------------------------------------
-- New Buyers
--------------------------------------------------
COUNT(DISTINCT IF(event_timestamp = user_first_touch_timestamp
                    AND event_name = 'purchase',
                    user_pseudo_id, NULL)) AS new_buyers,

--------------------------------------------------
-- Orders/Sales/Transactions
--------------------------------------------------
COUNT(DISTINCT transaction_id) AS orders

