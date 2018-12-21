 SELECT *
 FROM subscriptions
 Limit 100;
 
 
 Select DISTINCT segment, count(*) as Segment_Count
 From subscriptions
 Group by segment;
 
 SELECT Min(subscription_start),  
 Max(subscription_start) 
 From subscriptions;

WITH months AS
(
SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
UNION
SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
  cross_join AS (
  SELECT *
    From subscriptions
    CROSS JOIN  months
  ),
         
   status AS (
  SELECT 
    id,
    first_day AS month, 
    CASE
      WHEN (subscription_start < first_day) AND 
     (subscription_end > first_day OR subscription_end is NULL) AND (segment = 87) 
        THEN 1
      ELSE 0
    END AS is_active_87, 
    CASE
      WHEN (subscription_start < first_day) AND 
     (subscription_end > first_day OR subscription_end is NULL) AND (segment = 30) 
        THEN 1
      ELSE 0
    END AS is_active_30, 
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
     AND (segment = 87) 
        THEN 1
      ELSE 0
    END AS is_canceled_87, 
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
     AND (segment = 30)  
        THEN 1
      ELSE 0
    END AS is_canceled_30
  FROM cross_join 
),

status_aggregate AS (
SELECT SUM(is_active_87) as sum_active_87, 
SUM(is_active_30) as sum_active_30, 
SUM(is_canceled_87) as sum_canceled_87, 
SUM(is_canceled_30) as sum_canceled_30
  FROM status
  Group by month
)
SELECT month, 
1.0*sum_canceled_87/sum_active_87 as Churn_87, 1.0*sum_canceled_30/sum_active_30 AS Churn_30
From status_aggregate;


