-- accounts_user
USE docker_mysql;

SELECT COUNT(*)
FROM accounts_user
;

SELECT *
FROM accounts_user
LIMIT 100
;

SELECT COUNT(DISTINCT id)
FROM accounts_user
;

SELECT is_staff, COUNT(*)
FROM accounts_user
GROUP BY 1
;

SELECT gender,COUNT(*)
FROM accounts_user
GROUP BY 1
;

SELECT id, point
FROM accounts_user
ORDER BY point DESC
LIMIT 10
;

SELECT *
FROM accounts_user
WHERE id = 1577938
;

SELECT * 
FROM accounts_user
WHERE is_staff = 1
;

SELECT id, point, friend_id_list
FROM accounts_user
ORDER BY LENGTH(friend_id_list) DESC
LIMIT 50
;

SELECT id,
    LENGTH(friend_id_list) - LENGTH(REPLACE(friend_id_list, ',', '')) + 1 AS friend_count,
    point
FROM accounts_user
ORDER BY 2 DESC
LIMIT 10
;


SELECT AVG(point) AS point_avg
FROM (
    SELECT point,
        ROW_NUMBER() OVER (ORDER BY point DESC) AS rn
    FROM accounts_user
) AS t 
WHERE rn > 2
;

SELECT COUNT(*)
FROM accounts_user
WHERE friend_id_list = '[]'
;

SELECT id,
 LENGTH(friend_id_list) - LENGTH(REPLACE(friend_id_list, ',', '')) + 1 AS friend_count
FROM accounts_user
ORDER BY 2 DESC
LIMIT 10
;

SELECT is_push_on, COUNT(*)
FROM accounts_user
GROUP BY 1
;

SELECT COUNT(*)
FROM accounts_user
WHERE block_user_id_list != '[]'
;

SELECT id,
 LENGTH(block_user_id_list) - LENGTH(REPLACE(block_user_id_list, ',', '')) + 1 AS block_count
FROM accounts_user
ORDER BY 2 DESC
LIMIT 10
;

SELECT AVG(
 LENGTH(block_user_id_list) - LENGTH(REPLACE(block_user_id_list, ',', '')) + 1) AS block_count_avg
FROM accounts_user
WHERE block_user_id_list != '[]'
;

SELECT COUNT(*)
FROM accounts_user
WHERE hide_user_id_list != '[]'
;

SELECT id,
 LENGTH(hide_user_id_list) - LENGTH(REPLACE(hide_user_id_list, ',', '')) + 1 AS hide_id_count
FROM accounts_user
ORDER BY 2 DESC
LIMIT 10
;

SELECT AVG(
 LENGTH(hide_user_id_list) - LENGTH(REPLACE(hide_user_id_list, ',', '')) + 1) AS hide_count_avg
FROM accounts_user
WHERE block_user_id_list != '[]'
;

SELECT DISTINCT ban_status
FROM accounts_user
;
SELECT ban_status, COUNT(*)
FROM accounts_user
GROUP BY ban_status
;

SELECT MIN(created_at)
FROM accounts_user
;

SELECT
  COUNT(*) AS users,
  AVG(pending_chat)  AS avg_pending_chat,
  MAX(pending_chat)  AS max_pending_chat,
  AVG(pending_votes) AS avg_pending_votes,
  MAX(pending_votes) AS max_pending_votes
FROM accounts_user
;

-- users_with_pending
SELECT
  COUNT(*) AS users,
  SUM(CASE WHEN pending_chat > 0 OR pending_votes > 0 THEN 1 ELSE 0 END) AS users_with_pending,
  ROUND(
    100.0 * SUM(CASE WHEN pending_chat > 0 OR pending_votes > 0 THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_with_pending
FROM accounts_user
;

-- friend_count
SELECT
  CASE
    WHEN friend_id_list IS NULL OR friend_id_list = '[]' THEN 0
    ELSE JSON_LENGTH(friend_id_list)
  END AS friend_cnt,
  COUNT(*) AS users
FROM accounts_user
GROUP BY friend_cnt
ORDER BY friend_cnt
;

-- report_bucket
SELECT
  CASE
    WHEN report_count = 0 THEN '0'
    WHEN report_count BETWEEN 1 AND 3 THEN '1-3'
    ELSE '4+'
  END AS report_bucket,
  COUNT(*) AS users
FROM accounts_user
GROUP BY report_bucket
;

-- pending_bucket
SELECT
  CASE
    WHEN pending_chat = 0 THEN '0'
    WHEN pending_chat BETWEEN 1 AND 5 THEN '1-5'
    ELSE '6+'
  END AS pending_bucket,
  COUNT(*) AS users
FROM accounts_user
GROUP BY pending_bucket
;

-- is_push_on
SELECT
  is_push_on,
  COUNT(*) AS users
FROM accounts_user
GROUP BY is_push_on
;

-- point_bucket
SELECT
  CASE
    WHEN point = 0 THEN '0'
    WHEN point BETWEEN 1 AND 500 THEN '1-500'
    WHEN point BETWEEN 501 AND 2000 THEN '501-2000'
    ELSE '2000+'
  END AS point_bucket,
  COUNT(*) AS users
FROM accounts_user
GROUP BY point_bucket
;

