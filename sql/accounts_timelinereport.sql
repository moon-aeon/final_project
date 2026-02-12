-- accounts_timelinereport
USE docker_mysql;
SELECT COUNT(*)
FROM accounts_timelinereport
;

SELECT *
FROM accounts_timelinereport
LIMIT 100
;

SELECT COUNT(DISTINCT user_id)
FROM accounts_timelinereport
;

SELECT COUNT(DISTINCT reported_user_id)
FROM accounts_timelinereport
;

SELECT COUNT(DISTINCT reason)
FROM accounts_timelinereport
;

SELECT DISTINCT reason
FROM accounts_timelinereport
;

SELECT reason, COUNT(*)
FROM accounts_timelinereport
GROUP BY reason
;

SELECT MAX(created_at)
FROM accounts_timelinereport
;

SELECT MIN(created_at)
FROM accounts_timelinereport
;