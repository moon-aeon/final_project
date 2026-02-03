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

SELECT MIN(created_at)
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