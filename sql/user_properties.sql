-- 유저 속성

SELECT * FROM user_properties;

-- 유저 수: 230,819명
SELECT
    COUNT(DISTINCT user_id)
FROM user_properties;

-- 성별 수: 남 - 98,209명 / 여 - 132,610명
SELECT
    gender,
    COUNT(user_id)
FROM user_properties
GROUP BY gender;

-- 참여 학교 수: 5,023개
SELECT 
    COUNT(DISTINCT school_id)
FROM user_properties

-- 학년별 참여자 수: 1-3학년
SELECT
    grade,
    COUNT(DISTINCT user_id)
FROM user_properties
GROUP BY grade

-- 학교별 class 수가 많을수록 참여 학생이 많은지 확인, 중학교/고등학교 구분필요
WITH class_count AS (    
    SELECT
        school_id,
        COUNT(DISTINCT class) AS class_count
        -- * COUNT(class)
    FROM user_properties
    GROUP BY school_id
)
SELECT
    *
FROM (
    SELECT 
        school_id,
        COUNT(user_id) AS student_count
    FROM user_properties
    GROUP BY school_id
) AS student_count
LEFT JOIN class_count AS cc
    ON student_count.school_id = cc.school_id
ORDER BY student_count DESC
;


-- SELECT 
--     school_id, 
--     grade,
--     ROW_NUMBER() OVER(
--         PARTITION BY grade
--     )
-- FROM user_properties 
-- WHERE school_id = 1824
-- GROUP BY school_id