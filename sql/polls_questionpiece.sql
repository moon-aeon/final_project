-- 18. polls_questionpiece

DESCRIBE `polls_questionpiece`;

--1265476
SELECT COUNT(*) AS total_question_pieces
FROM `polls_questionpiece`;

-- 질문 당 조각 수 확인
SELECT
  `question_id`,
  COUNT(*) AS piece_cnt
FROM `polls_questionpiece`
GROUP BY `question_id`
ORDER BY piece_cnt DESC;


-- is_voted 분포
SELECT
  `is_voted`,
  COUNT(*) AS cnt,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM `polls_questionpiece`),
    2
  ) AS pct
FROM `polls_questionpiece`
GROUP BY `is_voted`;

-- is_skipped 분포
SELECT
  `is_skipped`,
  COUNT(*) AS cnt,
  ROUND(
    100 * COUNT(*) / (SELECT COUNT(*) FROM `polls_questionpiece`),
    2
  ) AS pct
FROM `polls_questionpiece`
GROUP BY `is_skipped`;

-- is_voted × is_skipped
SELECT
  `is_voted`,
  `is_skipped`,
  COUNT(*) AS cnt
FROM `polls_questionpiece`
GROUP BY `is_voted`, `is_skipped`
ORDER BY cnt DESC;


-- 
SELECT
  `question_id`,
  COUNT(*) AS total_pieces,
  SUM(`is_voted` = 1) AS voted_cnt,
  ROUND(
    100 * SUM(`is_voted` = 1) / COUNT(*),
    2
  ) AS vote_rate_pct
FROM `polls_questionpiece`
GROUP BY `question_id`
ORDER BY vote_rate_pct DESC;






