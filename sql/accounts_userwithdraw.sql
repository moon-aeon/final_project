-- 14. accounts_userwithdraw

DESCRIBE `accounts_userwithdraw`;

SELECT COUNT(*) FROM `accounts_userwithdraw`;)  -- 70764

-- reason
SELECT
  `reason`,
  COUNT(*) AS cnt
FROM `accounts_userwithdraw`
GROUP BY `reason`
ORDER BY cnt DESC;

-- 기타 이유 > 함계 할 친구가 없어서 > 재밌는 질문이 없어서 > 버그가 너무 많아서 > 구독료가 너무 비싸서 > admin > test > 갸타

SELECT MIN(`created_at`), MAX(`created_at`) 
FROM `accounts_userwithdraw`;

-- MIN: 2023-03-29 13:22:12
-- MAX: 2024-05-09 08:49:06

SELECT
  SUM(`reason` IS NULL) AS null_reason_cnt,
  SUM(TRIM(`reason`) = '') AS empty_reason_cnt
FROM `accounts_userwithdraw`;

-- 일별 탈퇴 추이 (트렌드)
SELECT
  DATE(`created_at`) AS withdraw_date,
  COUNT(*) AS cnt
FROM `accounts_userwithdraw`
GROUP BY DATE(`created_at`)
ORDER BY cnt DESC;

-- 월별 탈퇴 추이 (장기 패턴)
SELECT
  DATE_FORMAT(`created_at`, '%Y-%m') AS ym,
  COUNT(*) AS cnt
FROM `accounts_userwithdraw`
GROUP BY DATE_FORMAT(`created_at`, '%Y-%m')
ORDER BY cnt DESC;

-- 월 × 탈퇴 사유 분포
SELECT
  DATE_FORMAT(`created_at`, '%Y-%m') AS ym,
  `reason`,
  COUNT(*) AS cnt
FROM `accounts_userwithdraw`
GROUP BY ym, `reason`
ORDER BY cnt DESC;