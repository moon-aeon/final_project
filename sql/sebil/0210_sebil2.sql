DESCRIBE accounts_paymenthistory;
SELECT * FROM accounts_paymenthistory LIMIT 10;

SELECT COUNT(id) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT COUNT(user_id) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT DISTINCT productId FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT COUNT(*) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
AND productId = 'heart.200';

SELECT COUNT(*) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
AND productId = 'heart.777';

SELECT COUNT(*) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
AND productId = 'heart.1000';

SELECT COUNT(*) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
AND productId = 'heart.4000';

SELECT COUNT(*) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
AND phone_type = 'A';

SELECT COUNT(*) FROM accounts_paymenthistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
AND phone_type = 'I';











-------------------------------------------------------------------------------------
DESCRIBE accounts_pointhistory;
SELECT * FROM accounts_pointhistory LIMIT 10;

SELECT COUNT(id) FROM accounts_pointhistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT COUNT(user_id) FROM accounts_pointhistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT DISTINCT delta_point FROM accounts_pointhistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
ORDER BY delta_point;

SELECT COUNT(DISTINCT user_question_record_id) FROM accounts_pointhistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

-- 날짜별 투표 수
SELECT COUNT(user_question_record_id) AS total_vote, EXTRACT (DAY FROM created_at) AS vote_day
FROM accounts_pointhistory
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
GROUP BY vote_day
ORDER BY vote_day;


-------------------------------------------------------------------------------------
DESCRIBE accounts_timelinereport;
SELECT * FROM accounts_timelinereport LIMIT 10;

SELECT COUNT(id) FROM accounts_timelinereport
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT COUNT(user_id) FROM accounts_timelinereport
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT DISTINCT reason FROM accounts_timelinereport
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT
  EXTRACT (DAY FROM created_at) AS day,
  reason,
  COUNT(*) AS reason_count
FROM accounts_timelinereport
WHERE created_at >= '2023-05-01'
  AND created_at < '2023-06-01'
GROUP BY
  EXTRACT (DAY FROM created_at),
  reason
ORDER BY
  day,
  reason;

