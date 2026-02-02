-- 17. polls_question

DESCRIBE `polls_question`;

-- 5025
SELECT COUNT(*) AS total_questions
FROM `polls_question`;

-- 질문 형태
SELECT
  `question_text`,
  COUNT(*) AS cnt
FROM `polls_question`
GROUP BY `question_text`
ORDER BY cnt DESC;


-- 질문 생성 추이 (월별)
SELECT
  DATE_FORMAT(`created_at`, '%Y-%m') AS ym,
  COUNT(*) AS question_cnt
FROM `polls_question`
GROUP BY DATE_FORMAT(`created_at`, '%Y-%m')
ORDER BY ym;

SELECT
  DATE_FORMAT(`created_at`, '%Y-%m-%d') AS ym,
  COUNT(*) AS question_cnt
FROM `polls_question`
GROUP BY DATE_FORMAT(`created_at`, '%Y-%m-%d')
ORDER BY ym;


SELECT
  DATE(`created_at`) AS vote_date,
  COUNT(*) AS vote_cnt
FROM `accounts_userquestionrecord`
GROUP BY DATE(`created_at`)
ORDER BY vote_cnt DESC
LIMIT 1;

--2023년 5월 탈퇴 폭증 원인 추적
SELECT
  DATE(`created_at`) AS dt,
  COUNT(*) AS question_cnt
FROM `polls_question`
WHERE `created_at` BETWEEN '2023-05-01' AND '2023-05-31'
GROUP BY DATE(`created_at`)
ORDER BY question_cnt DESC;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM polls_question; 