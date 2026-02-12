-- accounts_pointhistory
USE docker_mysql;
SELECT COUNT(*)
FROM accounts_pointhistory
;

SELECT COUNT(DISTINCT user_id)
FROM accounts_pointhistory
;

SELECT * 
FROM accounts_pointhistory
LIMIT 100
;

SELECT COUNT(DISTINCT user_question_record_id)
FROM accounts_pointhistory
;

SELECT MIN(delta_point)
FROM accounts_pointhistory
;

SELECT AVG(delta_point)
FROM accounts_pointhistory
;

SELECT MAX(created_at)
FROM accounts_pointhistory
;

SELECT * 
FROM accounts_pointhistory
ORDER BY delta_point DESC
LIMIT 100
;

SELECT DISTINCT delta_point
FROM accounts_pointhistory
ORDER BY delta_point
;

SELECT
  CASE WHEN p.user_id IS NULL THEN 'no_point_history' ELSE 'has_point_history' END AS grp,
  COUNT(*) AS user_cnt,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS ratio_pct
FROM accounts_user u
LEFT JOIN (
  SELECT DISTINCT user_id
  FROM accounts_pointhistory
) p ON p.user_id = u.id
GROUP BY grp;

-- 기준일(데이터 최신일)로부터 14일 이상 활동 없으면 churn 후보
SELECT
  COUNT(*) AS churn_candidate_users
FROM (
  SELECT user_id
  FROM accounts_pointhistory
  GROUP BY user_id
  HAVING MAX(created_at) < '2024-05-08 01:36:18' - INTERVAL 14 DAY
) t;

SELECT
  churn_users,
  total_users,
  ROUND(100.0 * churn_users / total_users, 2) AS churn_rate_pct
FROM (
  SELECT
    (SELECT COUNT(*) FROM (
        SELECT user_id
        FROM accounts_pointhistory
        GROUP BY user_id
        HAVING MAX(created_at) < '2024-05-08 01:36:18' - INTERVAL 14 DAY
     ) a) AS churn_users,
    (SELECT COUNT(DISTINCT user_id) FROM accounts_pointhistory) AS total_users
) x;

SELECT
  DATE(created_at) AS dt,
  COUNT(*) AS event_cnt
FROM accounts_pointhistory
WHERE created_at >= '2023-04-01'
  AND created_at <  '2023-07-01'
GROUP BY DATE(created_at)
ORDER BY dt
;