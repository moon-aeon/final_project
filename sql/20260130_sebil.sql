-- accounts_userwithdraw, hackle_events

-- 날짜 확인
SELECT 
    COUNT(*) AS total_withdrawals,
    MIN(created_at) AS first_withdrawal,
    MAX(created_at) AS last_withdrawal
FROM accounts_userwithdraw;

SELECT 
    COUNT(*) AS total_events,
    MIN(event_datetime) AS first_event,
    MAX(event_datetime) AS last_event
FROM hackle_events;

-- 탈퇴 전체 추세
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS ym,
    COUNT(*) AS withdrawals
FROM accounts_userwithdraw
GROUP BY ym
ORDER BY withdrawals DESC;

-- 2023-05	44845 ***
-- 2023-06	9642
-- 2023-07	4811
-- 2023-09	2450
-- 2023-04	2397 **
-- 2023-08	2310
-- 2023-10	1164 **

-- 탈퇴 전체 추세 (day 포함)
SELECT 
    DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd,
    COUNT(*) AS withdrawals
FROM accounts_userwithdraw
GROUP BY ymd
ORDER BY ymd;

-- 탈퇴 이유 분포 (스파이크(탈퇴 급증) 전후)
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS ym,
    reason,
    COUNT(*) AS cnt
FROM accounts_userwithdraw
WHERE created_at >= '2023-02-01'
  AND created_at <  '2023-08-31'
GROUP BY ym, reason
ORDER BY ym, cnt DESC;

-- 
