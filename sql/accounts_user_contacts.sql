-- accounts_user_contacts table 
USE docker_mysql;
SELECT COUNT(*)
FROM accounts_user_contacts
;

SELECT * 
FROM accounts_user_contacts
LIMIT 100
;

SELECT COUNT(DISTINCT user_id)
FROM accounts_user_contacts
;

SELECT COUNT(*)
FROM accounts_user_contacts
WHERE invite_user_id_list = '[]'
;

SELECT * 
FROM accounts_user_contacts
ORDER BY LENGTH(invite_user_id_list) DESC
LIMIT 100
;

SELECT AVG(contacts_count)
FROM accounts_user_contacts
;

SELECT COUNT(*)
FROM accounts_user_contacts
WHERE contacts_count = 0
;

WITH contacts AS (
  SELECT
    user_id,
    COALESCE(contacts_count, 0) AS contacts_count,
CASE
  WHEN invite_user_id_list IS NULL OR TRIM(invite_user_id_list) = '' THEN 0
  ELSE 1 + LENGTH(invite_user_id_list) - LENGTH(REPLACE(invite_user_id_list, ',', ''))
END AS invite_count
  FROM accounts_user_contacts
)
SELECT *
FROM contacts
LIMIT 10;

WITH contacts AS (
  SELECT
    user_id,
    COALESCE(contacts_count, 0) AS contacts_count
  FROM accounts_user_contacts
)
SELECT
  contacts_count,
  COUNT(*) AS user_cnt
FROM contacts
GROUP BY contacts_count
ORDER BY contacts_count;

