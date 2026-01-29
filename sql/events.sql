-- 16. events

DESCRIBE `events`;

-- count: 3
SELECT COUNT(*) AS total_events
FROM `events`;

-- event 확인: FCFS ??
SELECT `event_type` FROM `events`;

-- 이벤트 생성 기간
SELECT
  MIN(`created_at`) AS first_event_at,
  MAX(`created_at`) AS last_event_at
FROM `events`;


-- 이벤트 생성 추이 (월별)
SELECT
  DATE_FORMAT(`created_at`, '%Y-%m') AS ym,
  COUNT(*) AS cnt
FROM `events`
GROUP BY DATE_FORMAT(`created_at`, '%Y-%m')
ORDER BY ym;

