select * from polls_questionpiece;
select COUNT(*) from polls_questionpiece;

-- is_voted는 ping에 답변을 했냐 하지 않았냐를 나타냄
select DISTINCT is_voted FROM polls_questionpiece;
select DISTINCT * FROM polls_questionpiece WHERE is_voted = 0;

-- is_skipped는 해당 질문에 대한 답변을 건너뛰었는지를 나타냄
select DISTINCT is_skipped FROM polls_questionpiece;

-- 하나의 질문 세트는 10개의 질문으로 구성되어 있다.
-- 데이터는 
select 
    created_at,
    COUNT(question_id) AS question_count
FROM polls_questionpiece
GROUP BY created_at
ORDER BY question_count ASC
;

SELECT
    *
FROM polls_questionpiece
WHERE created_at = '2023-05-20 14:45:37'
;

SELECT
    *
FROM polls_questionpiece
WHERE created_at = '2023-04-30 13:14:01'
;

SELECT
    *
FROM polls_questionpiece
WHERE is_skipped = 1;

SELECT
    *
FROM polls_questionpiece
WHERE is_voted = 0;
