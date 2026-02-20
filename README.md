# GA4 BigQuery SQL Cheat Sheet

SQL definitions of GA4 metrics and dimensions using raw export data in BigQuery.  
Focused on SEO and eCommerce web analytics use cases.

---

# Users
```sql
COUNT(DISTINCT user_pseudo_id) AS users
```

# Revenue
```sql
SELECT value.double_value FROM UNNEST(event_params) WHERE key='value' AS revenue
```

# Total Revenue
```sql
SUM(ecommerce.purchase_revenue) AS revenue
```

# Transaction ID
```sql
SELECT value.string_value FROM UNNEST(event_params) WHERE key='transaction_id') AS transaction_id
```

# New Users (Returning Users WHEN ELSE)
```sql
SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_number') = 1
```

# Unique Buyers
```sql
COUNT(DISTINCT IF(event_name='purchase', user_pseudo_id, NULL))
```

# New Buyers
```sql
COUNT(DISTINCT IF(event_timestamp = user_first_touch_timestamp
                    AND event_name = 'purchase',
                    user_pseudo_id, NULL)) AS new_buyers,
```

# Orders/Sales/Transactions
```sql
COUNT(DISTINCT transaction_id) AS orders
```
