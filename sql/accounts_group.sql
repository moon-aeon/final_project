-- 학급 테이블

SELECT * FROM accounts_group

SELECT distinct grade from accounts_group;

-- grade: 5가지 (4, 20은 잘못된 데이터 같음)
SELECT
    grade,
    COUNT(class_num)
FROM accounts_group
GROUP BY grade;

-- 참여 학교 수: 5,604개
SELECT
    COUNT(DISTINCT school_id)
FROM accounts_group

-- 학교별 활동 학년별 학급 수
WITH student_by_school AS (
    SELECT
        school_id,
        COUNT(grade) as student_count
    FROM accounts_group
    GROUP BY school_id
)
-- 학교별 활동 학생 수 최댓값과 최솟값: 1, 49
SELECT MIN(student_count), MAX(student_count) FROM student_by_school;

-- 평균 활동 학생 수: 15명
SELECT 
    AVG(student_count) 
FROM (
    SELECT
        school_id,
        COUNT(grade) as student_count
    FROM accounts_group
    GROUP BY school_id
) AS student_by_school;

WITH class_count AS (    
    SELECT
        school_id,
        COUNT(class) AS class_count
        -- * COUNT(class)
    FROM accounts_group
    GROUP BY school_id
)
SELECT
    *
FROM (
    SELECT 
        school_id,
        COUNT(user_id) AS student_count
    FROM accounts_group
    GROUP BY school_id
) AS student_count
LEFT JOIN class_count AS cc
    ON student_count.school_id = cc.school_id
ORDER BY student_count DESC
;