-- 이벤트 속성

SELECT * FROM hackle_properties;

-- 유저별 session_id 수(접속 횟수)
-- 평균: 1.6회
-- 최소: 1회
-- 최대: 82255회
SELECT 
    AVG(count),
    MIN(count),
    MAX(count)
FROM (
    SELECT 
        user_id,
        COUNT(session_id) AS count
    FROM hackle_properties
    GROUP BY user_id
) AS avg
;

-- 유저 수: 327,381명
SELECT COUNT(DISTINCT user_id) FROM hackle_properties;