-- 왜 망했을까? 마인드맵 찾아가기
-- 5월에 무슨 일이 있었을까 의 여정, 뭐라도 나오겠지

-- 2023년 4월~6월 일자별 가입자 및 탈퇴자 비교 쿼리
SELECT 
    DATE(created_at) AS event_date, 
    COUNT(id) AS daily_joins,
    0 AS daily_withdrawals
FROM accounts_user
WHERE created_at BETWEEN '2023-04-01' AND '2023-06-30'
GROUP BY 1

UNION ALL

SELECT 
    DATE(created_at) AS event_date, 
    0 AS daily_joins,
    COUNT(id) AS daily_withdrawals
FROM accounts_userwithdraw
WHERE created_at BETWEEN '2023-04-01' AND '2023-06-30'
GROUP BY 1
ORDER BY event_date ASC;


-- 컬럼에 값이 빈 NULL 이거나, 가입일보다 탈퇴일이 빠른 등의 오류 데이터 파악해보기 
-- accounts_user / accounts_userwithdraw / polls_questionpiece 
-- null
SELECT 
    'accounts_user' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_at,
    SUM(CASE WHEN group_id IS NULL THEN 1 ELSE 0 END) AS null_group_id -- 학교 소속이 없는 유저
FROM accounts_user

UNION ALL

SELECT 
    'accounts_userwithdraw' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_at,
    SUM(CASE WHEN reason IS NULL THEN 1 ELSE 0 END) AS null_reason
FROM accounts_userwithdraw

UNION ALL

SELECT 
    'polls_questionpiece' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN question_id IS NULL THEN 1 ELSE 0 END) AS null_question_id,
    SUM(CASE WHEN is_voted = 0 AND is_skipped = 0 THEN 1 ELSE 0 END) AS unhandled_data -- 투표도 스킵도 안 된 데이터
FROM polls_questionpiece;

-- 4월~ 6월 건너뛰기 비율 변화 보기
SELECT 
    DATE(created_at) AS event_date,
    -- 유효한 응답(투표 혹은 스킵)만 카운트
    SUM(CASE WHEN is_voted = 1 OR is_skipped = 1 THEN 1 ELSE 0 END) AS valid_responses,
    SUM(CASE WHEN is_voted = 1 THEN 1 ELSE 0 END) AS voted_count,
    SUM(CASE WHEN is_skipped = 1 THEN 1 ELSE 0 END) AS skipped_count,
    -- 전체 유효 응답 대비 스킵 비율
    ROUND(SUM(CASE WHEN is_skipped = 1 THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN is_voted = 1 OR is_skipped = 1 THEN 1 ELSE 0 END), 0), 2) AS skip_rate
FROM polls_questionpiece
WHERE created_at BETWEEN '2023-04-01' AND '2023-06-30'
GROUP BY 1
ORDER BY event_date ASC
;