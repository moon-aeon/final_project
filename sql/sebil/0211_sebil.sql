---------------accounts_userquestionrecord-----------------------------------------
DESCRIBE accounts_userquestionrecord;

SELECT * FROM accounts_userquestionrecord LIMIT 10;

SELECT COUNT(*) FROM accounts_userquestionrecord;

SELECT
  COUNT(*) AS total,
  COUNT(DISTINCT question_piece_id) AS distinct_pieces,
  COUNT(DISTINCT user_id) AS distinct_users,
  COUNT(DISTINCT question_id) AS distinct_questions,
  COUNT(DISTINCT chosen_user_id) AS distinct_chosen_users,
  COUNT(DISTINCT report_count)
FROM accounts_userquestionrecord;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM accounts_userquestionrecord;

SELECT
  SUM(`user_id` IS NULL) AS null_user_id,
  SUM(`chosen_user_id` IS NULL) AS null_chosen_user_id,
  SUM(`opened_times` IS NULL) AS null_opened_times,
  SUM(`status` IS NULL) AS null_status,
  SUM(`question_id` IS NULL) AS null_question_id,
  SUM(`question_piece_id` IS NULL) AS null_question_piece_id,
  SUM(`answer_status` IS NULL) AS null_answer_status,
  SUM(`answer_updated_at` IS NULL) AS null_answer_updated_at,
  SUM(`report_count` IS NULL) AS null_report_count,
  SUM(`has_read` IS NULL) AS null_has_read,
  SUM(`created_at` IS NULL) AS null_created_at
FROM `accounts_userquestionrecord`;

-- status 분포
SELECT
  `status`,
  COUNT(*) AS cnt,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM `accounts_userquestionrecord`), 2) AS pct
FROM `accounts_userquestionrecord`
GROUP BY `status`
ORDER BY cnt DESC;

-- answer_status 분포
SELECT
  `answer_status`,
  COUNT(*) AS cnt,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM `accounts_userquestionrecord`), 2) AS pct
FROM `accounts_userquestionrecord`
GROUP BY `answer_status`
ORDER BY cnt DESC;

-- status vs answer_status matching
SELECT
  `status`,
  `answer_status`,
  COUNT(*) AS cnt,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY `status`),
    2
  ) AS pct_within_status
FROM `accounts_userquestionrecord`
GROUP BY `status`, `answer_status`
ORDER BY `status`, cnt DESC;

-- 일별 투표 기록
SELECT
  DATE(created_at) AS dt,
  COUNT(*) AS vote_cnt
FROM accounts_userquestionrecord
GROUP BY DATE(created_at)
ORDER BY dt;

-- 월별 투표 기록
SELECT
    EXTRACT(YEAR FROM created_at) AS yr,
    EXTRACT(MONTH FROM created_at) AS mon,
    COUNT(*) AS vote_cnt
FROM accounts_userquestionrecord
GROUP BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
ORDER BY yr, mon;

SELECT
  user_id,
  COUNT(*) AS record_count
FROM accounts_userquestionrecord
GROUP BY user_id
ORDER BY record_count DESC
LIMIT 10;





-----------------------------------------------------------------------------------
---------------------------------accounts_userwithdraw-----------------------------
DESCRIBE accounts_userwithdraw;
SELECT * FROM accounts_userwithdraw LIMIT 10;

SELECT
  COUNT(*) AS total,
  COUNT(DISTINCT id),
  COUNT(DISTINCT reason)
FROM accounts_userwithdraw;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM accounts_userwithdraw;

-- reason
SELECT
  reason,
  COUNT(*) AS cnt
FROM accounts_userwithdraw
GROUP BY reason
ORDER BY cnt DESC;

-- 일별 탈퇴 추이 (트렌드)
SELECT
  DATE(`created_at`) AS withdraw_date,
  COUNT(*) AS cnt
FROM `accounts_userwithdraw`
GROUP BY DATE(`created_at`)
ORDER BY cnt DESC;

-- 월별 탈퇴 추이
SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS ym,
  COUNT(*) AS cnt
FROM accounts_userwithdraw
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY ym;

-- 월 × 탈퇴 사유 분포
SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS ym,
  reason,
  COUNT(*) AS cnt
FROM accounts_userwithdraw
GROUP BY ym, reason
ORDER BY ym;

-- 매월 "기타 이유"가 1순위라서(2023년 3월만 "재밌는 질문이 없어서") 두번째 이유를 찾기
WITH monthly_counts AS (
  SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS ym,
    reason,
    COUNT(*) AS cnt
  FROM accounts_userwithdraw
  GROUP BY ym, reason
),
ranked AS (
  SELECT
    ym,
    reason,
    cnt,
    ROW_NUMBER() OVER (PARTITION BY ym ORDER BY cnt DESC) AS rn
  FROM monthly_counts
)
SELECT
  ym,
  reason,
  cnt
FROM ranked
WHERE rn = 2
ORDER BY ym;


--------------------------------------------------------------------------
-----------------------------event_receipts-------------------------------
DESCRIBE event_receipts;
SELECT * FROM event_receipts;

SELECT
  COUNT(*) AS total,
  COUNT(DISTINCT id),
  COUNT(DISTINCT user_id),
  COUNT(DISTINCT event_id),
  COUNT(DISTINCT plus_point)
FROM event_receipts;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM event_receipts;

SELECT DISTINCT plus_point FROM event_receipts;
SELECT DISTINCT event_id FROM event_receipts;

SELECT
  event_id,
  MIN(created_at) AS event_start,
  MAX(created_at) AS event_end,
  COUNT(DISTINCT user_id) AS user_count
FROM event_receipts
GROUP BY event_id
ORDER BY event_id;

SELECT
  id,
  user_id,
  event_id,
  plus_point,
  created_at  
FROM event_receipts
WHERE user_id IN (
  SELECT user_id
  FROM event_receipts
  GROUP BY user_id
  HAVING COUNT(*) > 1
)
ORDER BY id;

SELECT COUNT(plus_point) FROM event_receipts;

SELECT plus_point, COUNT(user_id), DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd
FROM event_receipts
GROUP BY plus_point, ymd
ORDER BY ymd;


--------------------------------------------------------------------------------
---------------------------events-----------------------------------------------
DESCRIBE events;
SELECT * FROM events;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM events;

------------------------------------------------------------------------------
-----------------------------polls_question-----------------------------------
DESCRIBE polls_question;

SELECT * FROM polls_question LIMIT 10;

SELECT
  COUNT(*) AS total,
  COUNT(DISTINCT id),
  COUNT(DISTINCT question_text),
  COUNT(DISTINCT created_at)
FROM polls_question;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM polls_question;

SELECT COUNT(*), DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd
FROM polls_question
GROUP BY ymd
ORDER BY ymd;

SELECT
  question_text,
  COUNT(*) AS ask_count
FROM polls_question
GROUP BY question_text
ORDER BY ask_count DESC
LIMIT 10;

-----------------------------------------------------------------------------
--------------------------polls_questionpiece--------------------------------
DESCRIBE polls_questionpiece;

SELECT * FROM polls_questionpiece LIMIT 10;

SELECT
  COUNT(*) AS total,
  COUNT(DISTINCT id),
  COUNT(DISTINCT is_voted),
  COUNT(DISTINCT is_skipped),
  COUNT(DISTINCT question_id)
FROM polls_questionpiece;

SELECT
  MIN(created_at) AS min_created_at,
  MAX(created_at) AS max_created_at
FROM polls_questionpiece;

SELECT DISTINCT is_voted
FROM polls_questionpiece;

SELECT DISTINCT is_skipped
FROM polls_questionpiece;

SELECT DISTINCT COUNT(question_id), DATE_FORMAT(created_at, '%Y-%m') AS ym
FROM polls_questionpiece
GROUP BY ym
ORDER BY ym;

--투표 여부의 분포
SELECT
  is_voted,
  COUNT(*) AS count,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM polls_questionpiece) AS pct
FROM polls_questionpiece
GROUP BY is_voted;

--스킵 여부의 분포
SELECT
  is_skipped,
  COUNT(*) AS count,
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM polls_questionpiece) AS pct
FROM polls_questionpiece
GROUP BY is_skipped;

-- 가장 많이 응답 받은 질문 10가지
SELECT
  question_id,
  COUNT(*)
FROM polls_questionpiece
WHERE is_voted = '1' AND is_skipped = '0'
GROUP BY question_id
ORDER BY 2 DESC
LIMIT 10;

SELECT
  is_voted,
  is_skipped,
  COUNT(*) AS count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM polls_questionpiece
GROUP BY is_voted, is_skipped
ORDER BY count DESC;

-- 스킵 수 OR 응답 받지 않는 질문 수 분포
SELECT
  DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd,
  question_id,
  COUNT(*)
FROM polls_questionpiece
WHERE is_voted = '0'
GROUP BY question_id, ymd
ORDER BY 3 DESC
LIMIT 10;

SELECT
  DATE_FORMAT(created_at, '%Y-%m') AS ym,
  COUNT(question_id)
FROM polls_questionpiece
WHERE is_voted = '0' OR is_skipped = '1'
GROUP BY ym
ORDER BY ym;