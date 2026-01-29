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