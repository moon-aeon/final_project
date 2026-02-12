-- accounts_school
USE docker_mysql;
SELECT COUNT(*)
FROM accounts_school
;

SELECT * 
FROM accounts_school
LIMIT 100
;

SELECT COUNT(DISTINCT address)
FROM accounts_school
;

SELECT DISTINCT address
FROM accounts_school
;

SELECT DISTINCT address
FROM accounts_school
WHERE address LIKE '%인천%'
;

SELECT school_type,
    COUNT(*) as type_count
FROM accounts_school
GROUP BY school_type
;

SELECT COUNT(DISTINCT id) AS id_count
FROM accounts_school
;

SELECT COUNT(*)
FROM accounts_school
WHERE student_count = (
    SELECT MIN(student_count)
    FROM accounts_school
    WHERE student_count > 0
) 
;

SELECT id, address, student_count
FROM accounts_school
ORDER BY student_count DESC 
LIMIT 10
;

SELECT DISTINCT student_count
FROM accounts_school
ORDER BY student_count
LIMIT 5
;

SELECT
  school_type,
  SUM(student_count) AS total_students,
  ROUND(
    100.0 * SUM(student_count) /
    SUM(SUM(student_count)) OVER (),
  2) AS ratio_pct
FROM accounts_school
GROUP BY school_type
;