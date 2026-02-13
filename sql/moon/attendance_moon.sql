USE docker_mysql;
SELECT * FROM accounts_attendance
LIMIT 100
;

SELECT
  CASE
    WHEN JSON_LENGTH(a.attendance_date_list) = 1 THEN '1'
    WHEN JSON_LENGTH(a.attendance_date_list) BETWEEN 2 AND 3 THEN '2-3'
    WHEN JSON_LENGTH(a.attendance_date_list) BETWEEN 4 AND 7 THEN '4-7'
    ELSE '8+'
  END AS attend_days_bucket,
  COUNT(*) AS users
FROM accounts_attendance a
GROUP BY attend_days_bucket
ORDER BY FIELD(attend_days_bucket, '1','2-3','4-7','8+')
;

-- 단순 분포 확인 
SELECT
  s.school_type,
  COALESCE(NULLIF(TRIM(u.gender), ''), '(NULL)') AS gender,
  COALESCE(NULLIF(TRIM(up.grade), ''), '(NULL)') AS grade,
  COUNT(*) AS users,
  ROUND(AVG(JSON_LENGTH(a.attendance_date_list)), 2) AS avg_attend_days
FROM accounts_attendance a
JOIN accounts_user u ON u.id = a.user_id
JOIN user_properties up ON up.user_id = u.id
JOIN accounts_school s ON s.id = u.group_id
GROUP BY s.school_type, gender, grade
ORDER BY s.school_type, gender, avg_attend_days DESC
;

-- 단순 분포 확인
SELECT
  u.gender,
  JSON_LENGTH(a.attendance_date_list) AS attend_days,
  COUNT(*) AS users
FROM accounts_attendance a
JOIN accounts_user u ON u.id = a.user_id
GROUP BY u.gender, attend_days
ORDER BY u.gender, attend_days
;

SELECT
  up.grade,
  DATE_FORMAT(DATE(u.created_at), '%Y-%m') AS cohort_month,
  COUNT(*) AS cohort_users,

  ROUND(100.0 * AVG(
    COALESCE(
      JSON_CONTAINS(
        CAST(a.attendance_date_list AS JSON),
        CONCAT('"', DATE_FORMAT(DATE_ADD(DATE(u.created_at), INTERVAL 7 DAY), '%Y-%m-%d'), '"')
      ), 0)
  ), 2) AS d7_retention_pct,

  ROUND(100.0 * AVG(
    COALESCE(
      JSON_CONTAINS(
        CAST(a.attendance_date_list AS JSON),
        CONCAT('"', DATE_FORMAT(DATE_ADD(DATE(u.created_at), INTERVAL 14 DAY), '%Y-%m-%d'), '"')
      ), 0)
  ), 2) AS d14_retention_pct,

  ROUND(100.0 * AVG(
    COALESCE(
      JSON_CONTAINS(
        CAST(a.attendance_date_list AS JSON),
        CONCAT('"', DATE_FORMAT(DATE_ADD(DATE(u.created_at), INTERVAL 30 DAY), '%Y-%m-%d'), '"')
      ), 0)
  ), 2) AS d30_retention_pct

FROM accounts_user u
JOIN user_properties up
  ON up.user_id = u.id
LEFT JOIN accounts_attendance a
  ON a.user_id = u.id
WHERE DATE(u.created_at) <= '2024-05-08' - INTERVAL 30 DAY
GROUP BY up.grade, cohort_month
ORDER BY cohort_month, up.grade
;