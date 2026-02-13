USE docker_mysql;

SELECT COUNT(*) AS total_reports
FROM polls_questionreport
;

SELECT 
  ROUND(COUNT(*) / COUNT(DISTINCT question_id), 2) AS avg_reports_per_question
FROM polls_questionreport
;

SELECT
  question_id,
  COUNT(*) AS report_cnt
FROM polls_questionreport
GROUP BY question_id
ORDER BY report_cnt DESC
LIMIT 10
;

SELECT
  q.id,
  q.question_text,             
  COUNT(r.question_id) AS report_cnt
FROM polls_questionreport r
JOIN polls_question q
  ON r.question_id = q.id
GROUP BY q.id, q.question_text
ORDER BY report_cnt DESC
LIMIT 10
;

-- 외모 관련 키워드 포함 질문 신고 수
SELECT COUNT(*)
FROM polls_question q
JOIN polls_questionreport r ON q.id = r.question_id
WHERE q.question_text LIKE '%냄새%'
   OR q.question_text LIKE '%어깨%'
   OR q.question_text LIKE '%등빨%'
   OR q.question_text LIKE '%마스크%'
   ;
-- 1학년 여학생 전체 수 
SELECT COUNT(*) AS total_users
FROM accounts_user u
JOIN user_properties up ON up.user_id = u.id
WHERE up.grade = 1
  AND u.gender = 'F'
  ;
-- 1학년 여학생 중 신고한 유저 수 
SELECT COUNT(DISTINCT r.user_id) AS reporting_users
FROM polls_questionreport r
JOIN accounts_user u ON u.id = r.user_id
JOIN user_properties up ON up.user_id = u.id
WHERE up.grade = 1
  AND u.gender = 'F'
;

SELECT
  q.id,
  LEFT(q.question_text, 100) AS question_preview,
  COUNT(*) AS report_cnt
FROM polls_questionreport r
JOIN polls_question q ON q.id = r.question_id
JOIN accounts_user u ON u.id = r.user_id
JOIN user_properties up ON up.user_id = u.id
WHERE up.grade = 1
  AND u.gender = 'F'
GROUP BY q.id, q.question_text
ORDER BY report_cnt DESC
LIMIT 10
;

SELECT
  r.reason,
  COUNT(*) AS cnt
FROM polls_questionreport r
JOIN accounts_user u ON u.id = r.user_id
JOIN user_properties up ON up.user_id = u.id
WHERE up.grade = 1
  AND u.gender = 'F'
GROUP BY r.reason
ORDER BY cnt DESC
;