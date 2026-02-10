USE docker_mysql;

SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN opened_times > 0 THEN 1 ELSE 0 END) AS opened,
  SUM(CASE WHEN has_read = 1 THEN 1 ELSE 0 END) AS r,
  SUM(CASE WHEN answer_status <> 'N' THEN 1 ELSE 0 END) AS answered,
  SUM(CASE WHEN answer_status = 'A' THEN 1 ELSE 0 END) AS public_answer
FROM accounts_userquestionrecord
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5s
;

SELECT DISTINCT answer_status
FROM accounts_userquestionrecord
;