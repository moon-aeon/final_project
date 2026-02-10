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