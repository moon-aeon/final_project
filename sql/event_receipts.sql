-- 15. event_receipts

DESCRIBE `event_receipts`;

-- 전체 이벤트 참여 건수: 309
SELECT COUNT(*) AS total_event_receipt_cnt
FROM `event_receipts`;

-- user 기준 참여 현황 (중복 참여 확인):  1번??
SELECT
  COUNT(DISTINCT `user_id`) AS unique_users,
  COUNT(*) AS total_participation,
  ROUND(COUNT(*) / COUNT(DISTINCT `user_id`), 2) AS avg_events_per_user
FROM `event_receipts`;

-- 월별 이벤트 참여 & 포인트 추이
SELECT
  DATE_FORMAT(`created_at`, '%Y-%m') AS ym,
  COUNT(*) AS participation_cnt,
  SUM(`plus_point`) AS total_points
FROM `event_receipts`
GROUP BY DATE_FORMAT(`created_at`, '%Y-%m')
ORDER BY participation_cnt DESC;

