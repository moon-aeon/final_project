USE docker_mysql;

SELECT *
FROM accounts_user
LIMIT 100
;

-- school_type 별 gender 비율
SELECT
  s.school_type,
  u.gender,
  COUNT(*) AS user_cnt,
  ROUND(
    100.0 * COUNT(*) /
    SUM(COUNT(*)) OVER (),
  2) AS ratio_pct
FROM accounts_user u
JOIN accounts_school s
  ON u.group_id = s.id
GROUP BY s.school_type, u.gender
ORDER BY s.school_type, u.gender
;

-- 학교 타입 내 성별 비율 
SELECT
  school_type,
  gender,
  user_cnt,
  ROUND(
    100.0 * user_cnt /
    SUM(user_cnt) OVER (PARTITION BY school_type),
  2) AS ratio_within_school
FROM (
  SELECT
    s.school_type,
    u.gender,
    COUNT(*) AS user_cnt
  FROM accounts_user u
  JOIN accounts_school s
    ON u.group_id = s.id
  GROUP BY s.school_type, u.gender
) t
ORDER BY school_type, gender
;

SELECT
  COUNT(*) AS total_reports,
  SUM(
    CASE 
      WHEN u1.group_id = u2.group_id THEN 1 
      ELSE 0 
    END
  ) AS same_group_reports,
  ROUND(
    100.0 * SUM(CASE WHEN u1.group_id = u2.group_id THEN 1 ELSE 0 END)
    / COUNT(*),
  2) AS same_group_ratio
FROM accounts_timelinereport r
JOIN accounts_user u1 ON r.user_id = u1.id
JOIN accounts_user u2 ON r.reported_user_id = u2.id
;

SELECT
  s.school_type,
  COUNT(*) AS report_cnt
FROM accounts_timelinereport r
JOIN accounts_user u1 ON r.user_id = u1.id
JOIN accounts_user u2 ON r.reported_user_id = u2.id
JOIN accounts_school s ON u1.group_id = s.id
WHERE u1.group_id = u2.group_id
GROUP BY s.school_type
;

SELECT
    COUNT(*) AS total_reports,
    SUM(CASE WHEN up1.school_id = up2.school_id THEN 1 ELSE 0 END) AS same_school_cnt,
    ROUND(
        100.0 * SUM(CASE WHEN up1.school_id = up2.school_id THEN 1 ELSE 0 END) 
        / COUNT(*),
    2) AS same_school_ratio
FROM accounts_timelinereport r
JOIN user_properties up1 
    ON r.user_id = up1.user_id
JOIN user_properties up2 
    ON r.reported_user_id = up2.user_id
    ;

SELECT
  COUNT(*) AS total_reports,  -- report_table 전체
  SUM(CASE WHEN up1.user_id IS NULL THEN 1 ELSE 0 END) AS missing_reporter_profile,
  SUM(CASE WHEN up2.user_id IS NULL THEN 1 ELSE 0 END) AS missing_reported_profile,
  SUM(CASE WHEN up1.user_id IS NULL OR up2.user_id IS NULL THEN 1 ELSE 0 END) AS missing_either_side,
  SUM(CASE WHEN up1.user_id IS NOT NULL AND up2.user_id IS NOT NULL THEN 1 ELSE 0 END) AS matched_both_sides
FROM accounts_timelinereport r
LEFT JOIN user_properties up1 ON r.user_id = up1.user_id
LEFT JOIN user_properties up2 ON r.reported_user_id = up2.user_id;


SELECT
  COUNT(*) AS total_reports, -- 208 유지
  SUM(CASE WHEN up1.user_id IS NOT NULL AND up2.user_id IS NOT NULL THEN 1 ELSE 0 END) AS matched_both,
  SUM(CASE WHEN up1.user_id IS NULL OR up2.user_id IS NULL THEN 1 ELSE 0 END) AS unmatched_any_side,
  SUM(CASE WHEN up1.user_id IS NOT NULL AND up2.user_id IS NOT NULL 
            AND up1.school_id = up2.school_id THEN 1 ELSE 0 END) AS same_school_cnt,
  ROUND(
    100.0 * SUM(CASE WHEN up1.user_id IS NOT NULL AND up2.user_id IS NOT NULL 
                      AND up1.school_id = up2.school_id THEN 1 ELSE 0 END)
    / NULLIF(SUM(CASE WHEN up1.user_id IS NOT NULL AND up2.user_id IS NOT NULL THEN 1 ELSE 0 END), 0),
  2) AS same_school_ratio_among_matched
FROM accounts_timelinereport r
LEFT JOIN user_properties up1 ON r.user_id = up1.user_id
LEFT JOIN user_properties up2 ON r.reported_user_id = up2.user_id;

SELECT
  up.grade,
  COUNT(*) AS user_cnt,
  ROUND(100.0 * COUNT(*) / t.total_cnt, 2) AS ratio_pct
FROM accounts_user u
JOIN user_properties up
  ON u.id = up.user_id
JOIN (
  SELECT COUNT(*) AS total_cnt
  FROM accounts_user u2
  JOIN user_properties up2
    ON u2.id = up2.user_id
) t
GROUP BY up.grade, t.total_cnt
ORDER BY user_cnt DESC
;

SELECT
  s.school_type,
  COALESCE(NULLIF(TRIM(u.gender), ''), '(NULL)') AS gender,
  COALESCE(NULLIF(TRIM(up.grade), ''), '(NULL)') AS grade,
  COUNT(*) AS user_cnt,
  ROUND(100.0 * COUNT(*) / tot.total_cnt, 2) AS ratio_pct
FROM accounts_user u
JOIN user_properties up
  ON up.user_id = u.id
JOIN accounts_school s
  ON s.id = u.group_id
JOIN (
  SELECT COUNT(*) AS total_cnt
  FROM accounts_user u2
  JOIN user_properties up2 ON up2.user_id = u2.id
  JOIN accounts_school s2 ON s2.id = u2.group_id
) tot
GROUP BY s.school_type, gender, grade, tot.total_cnt
ORDER BY s.school_type, gender, user_cnt DESC
;

SELECT
  t.school_type,
  t.gender,
  t.grade,
  t.user_cnt,
  ROUND(100.0 * t.user_cnt / sch.total_cnt, 2) AS ratio_within_school_pct
FROM (
  SELECT
    s.school_type,
    COALESCE(NULLIF(TRIM(u.gender), ''), '(NULL)') AS gender,
    COALESCE(NULLIF(TRIM(up.grade), ''), '(NULL)') AS grade,
    COUNT(*) AS user_cnt
  FROM accounts_user u
  JOIN user_properties up ON up.user_id = u.id
  JOIN accounts_school s ON s.id = u.group_id
  GROUP BY s.school_type, gender, grade
) t
JOIN (
  SELECT
    s.school_type,
    COUNT(*) AS total_cnt
  FROM accounts_user u
  JOIN user_properties up ON up.user_id = u.id
  JOIN accounts_school s ON s.id = u.group_id
  GROUP BY s.school_type
) sch
  ON sch.school_type = t.school_type
ORDER BY t.school_type, t.gender, t.user_cnt DESC
;