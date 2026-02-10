USE docker_mysql;

SELECT * FROM accounts_user
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
LIMIT 100
;

SELECT COUNT(*)
FROM accounts_user
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
;


SELECT * FROM accounts_userquestionrecord
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
LIMIT 100
;

SELECT * FROM accounts_userwithdraw
LIMIT 100
;

SELECT id, point, LENGTH(friend_id_list) - LENGTH(REPLACE(friend_id_list, ',', '')) + 1 AS friend_count
FROM accounts_user
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
ORDER BY point DESC
LIMIT 10
;

SELECT MAX(point)
FROM accounts_user
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
;

SELECT id,
    LENGTH(friend_id_list) - LENGTH(REPLACE(friend_id_list, ',', '')) + 1 AS friend_count,
    point
FROM accounts_user
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
ORDER BY 2 DESC
LIMIT 10
;

SELECT
  MAX(friend_count) AS max_friend_count,
  AVG(friend_count) AS avg_friend_count
FROM (
  SELECT
    LENGTH(friend_id_list) - LENGTH(REPLACE(friend_id_list, ',', '')) + 1 AS friend_count
  FROM accounts_user
  WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
) t;

SELECT id,
    LENGTH(block_user_id_list) - LENGTH(REPLACE(block_user_id_list, ',', '')) + 1 AS block_count,
    point,
    ban_status
FROM accounts_user
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
ORDER BY 2 DESC
LIMIT 10
;

SELECT
  MAX(block_count) AS max_block_count,
  AVG(block_count) AS avg_block_count
FROM (
  SELECT
    LENGTH(block_user_id_list) - LENGTH(REPLACE(block_user_id_list, ',', '')) + 1 AS block_count
  FROM accounts_user
  WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5
) t;

SELECT
  ban_status,
  COUNT(*) AS user_count,
  ROUND(AVG(friend_count), 2) AS avg_friend_count,
  MAX(friend_count) AS max_friend_count
FROM (
  SELECT
    ban_status,
    CASE
      WHEN friend_id_list IS NULL OR friend_id_list = '' THEN 0
      ELSE LENGTH(friend_id_list) - LENGTH(REPLACE(friend_id_list, ',', '')) + 1
    END AS friend_count
  FROM accounts_user
) t
GROUP BY ban_status;

SELECT
  COUNT(*) AS users,
  AVG(pending_chat)  AS avg_pending_chat,
  MAX(pending_chat)  AS max_pending_chat,
  AVG(pending_votes) AS avg_pending_votes,
  MAX(pending_votes) AS max_pending_votes
FROM accounts_user
WHERE created_at >= '2023-05-01'
  AND created_at <  '2023-06-01';

SELECT
  COUNT(*) AS users,
  SUM(CASE WHEN pending_chat > 0 OR pending_votes > 0 THEN 1 ELSE 0 END) AS users_with_pending,
  ROUND(
    100.0 * SUM(CASE WHEN pending_chat > 0 OR pending_votes > 0 THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pct_with_pending
FROM accounts_user
WHERE created_at >= '2023-05-01'
  AND created_at <  '2023-06-01';

SELECT id, pending_chat, pending_votes, created_at
FROM accounts_user
WHERE created_at >= '2023-05-01'
  AND created_at <  '2023-06-01'
ORDER BY (pending_chat + pending_votes) DESC
LIMIT 20;