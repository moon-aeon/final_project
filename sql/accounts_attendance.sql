-- 출석 테이블
-- 유저 아이디, 출석 날짜 리스트
-- 질문
    -- 유저 수
    -- 최다 출석 수
    -- 일별 출석 수
    -- 주말/주중 평균 출석 수
    -- 

SELECT * FROM accounts_attendance;

-- 유저 수: 349,637명
SELECT COUNT(DISTINCT user_id) AS user_count
FROM accounts_attendance
;

-- 기간: 2023-05-27 ~ 2024-05-09
SELECT
    MIN(min_date) AS min_date,
    MAX(max_date) AS max_date
FROM (    
    SELECT 
        user_id,
        MIN(CAST(attendance_date AS DATE)) AS min_date,
        MAX(CAST(attendance_date AS DATE)) AS max_date
    FROM accounts_attendance,
        JSON_TABLE(attendance_date_list, '$[*]' COLUMNS (attendance_date VARCHAR(20) PATH '$')) AS jt
    GROUP BY user_id
) AS date_range
;

-- 최다 출석 일 수: 310일
SELECT 
    user_id,
    COUNT(attendance_date) AS attendance_count
FROM accounts_attendance,
    JSON_TABLE(attendance_date_list, '$[*]' COLUMNS (attendance_date VARCHAR(20) PATH '$')) AS jt
GROUP BY user_id
ORDER BY COUNT(attendance_date) DESC
LIMIT 1
;

-- 평균 출석 일 수: 6.8일
SELECT 
    AVG(attendance_count)
FROM (
    SELECT 
        user_id,
        COUNT(attendance_date) AS attendance_count
    FROM accounts_attendance,
        JSON_TABLE(attendance_date_list, '$[*]' COLUMNS (attendance_date VARCHAR(20) PATH '$')) AS jt
    GROUP BY user_id
    ORDER BY COUNT(attendance_date) DESC
) AS attendance_count
;

-- 일별 출석
-- SELECT
--     attendance_date,
--     COUNT(user_id) AS user_count
-- FROM accounts_attendance,
--      JSON_TABLE(attendance_date_list, '$[*]' COLUMNS (attendance_date VARCHAR(20) PATH '$')) AS jt
-- GROUP BY attendance_date
-- ;



