-- 탐색 목적: 업데이트 전에는 서비스 이용이 무료였나?
SELECT * FROM polls_question;

SELECT COUNT(question_text) FROM polls_question;
SELECT COUNT(DISTINCT question_text) FROM polls_question;

-- (1) 업데이트 전 ping 이용량 비교
-- 집계 기간: 2023-03-31 15:22:53 ~ 2023-06-06 06:15:52
SELECT 
    MIN(created_at),
    MAX(created_at)
FROM polls_question
;

-- 월별 질문량
SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(question_text) AS count
FROM polls_question
-- WHERE created_at < '2023-05-13'
GROUP BY year, month
;

-- 일별 질문량
-- ping을 사용한 게 8일 밖에 되지 않음
-- 5월 15일부터 사용량 급증 (1.5 업데이트 5월 13일)
-- 하지만 데이터가 6월 6일까지밖에 없다.
-- 
SELECT
    DATE(created_at) AS date,
    COUNT(question_text) AS count
FROM polls_question
GROUP BY date;


