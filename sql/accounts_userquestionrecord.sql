-- EDA

-- 13. accounts_userquestionrecord

SELECT COUNT(*) FROM `accounts_userquestionrecord`;  -- 1217558

DESCRIBE `accounts_userquestionrecord`;     -- id: PK

SELECT
  MIN(`created_at`) AS min_created_at,
  MAX(`created_at`) AS max_created_at
FROM `accounts_userquestionrecord`;         -- min: 2023-04-28 12:27:49
                                            -- max: 2024-05-08 01:36:18

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
FROM `accounts_userquestionrecord`;                     -- NULL: 0

-- status 분포
SELECT
  `status`,
  COUNT(*) AS cnt,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM `accounts_userquestionrecord`), 2) AS pct
FROM `accounts_userquestionrecord`
GROUP BY `status`
ORDER BY cnt DESC;

-- Closed: 1156322 (94.97%)
-- Initial: 60578 (4.98%)
-- Blocked: 658 (0.05%)

-- answer_status 분포
SELECT
  `answer_status`,
  COUNT(*) AS cnt,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM `accounts_userquestionrecord`), 2) AS pct
FROM `accounts_userquestionrecord`
GROUP BY `answer_status`
ORDER BY cnt DESC;

-- Not answered: 1097932 (90.17%)
-- Available: 111761 (9.18%)
-- Private: 7865 (0.65%)

----------------------------------------------
-- Closed 상태에서 정말 Not Answered가 많은지 확인

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

-- Closed & Not Answered만 보기: 1048759

SELECT
  COUNT(*) AS closed_not_answered_cnt
FROM `accounts_userquestionrecord`
WHERE `status` = 'C'
  AND `answer_status` = 'N';

-- Closed만 보기: 1156322
SELECT
  COUNT(*) AS total_closed_cnt
FROM `accounts_userquestionrecord`
WHERE `status` = 'C';


-- 같은 기간 투표 기록 폭증 여부
SELECT
  DATE(`created_at`) AS dt,
  COUNT(*) AS vote_cnt
FROM `accounts_userquestionrecord`
WHERE `created_at` BETWEEN '2023-05-01' AND '2023-05-31'
GROUP BY DATE(`created_at`)
ORDER BY dt DESC;