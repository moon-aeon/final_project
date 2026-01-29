-- hackle_events 테이블 뜯어보기
-- null 파악해보기 
SELECT
  SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS event_id_null,
  SUM(CASE WHEN event_key IS NULL THEN 1 ELSE 0 END) AS event_key_null,
  SUM(CASE WHEN session_id IS NULL THEN 1 ELSE 0 END) AS session_id_null,
  SUM(CASE WHEN item_name IS NULL THEN 1 ELSE 0 END) AS item_name_null,
  SUM(CASE WHEN page_name IS NULL THEN 1 ELSE 0 END) AS page_name_null,
  SUM(CASE WHEN friend_count IS NULL THEN 1 ELSE 0 END) AS friend_count_null,
  SUM(CASE WHEN votes_count IS NULL THEN 1 ELSE 0 END) AS votes_count_null,
  SUM(CASE WHEN heart_balance IS NULL THEN 1 ELSE 0 END) AS heart_balance_null,
  SUM(CASE WHEN question_id IS NULL THEN 1 ELSE 0 END) AS question_id_null
FROM hackle_events
;

-- 고유값 or 전체 수 
SELECT 
    COUNT(event_datetime)
FROM hackle_events
;

-- 이벤트 전체 볼륨 및 기간 확인 
SELECT
  MIN(event_datetime) AS min_time,
  MAX(event_datetime) AS max_time,
  COUNT(*) AS total_events,
  COUNT(DISTINCT session_id) AS sessions
FROM hackle_events;

-- 이벤트 키 분포 파악(사용자 행동 파악)
SELECT
  event_key,
  COUNT(*) AS event_cnt,
  COUNT(DISTINCT session_id) AS session_cnt,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
  ) AS ratio
FROM hackle_events
GROUP BY event_key
ORDER BY event_cnt DESC;

-- 세션당 이벤트 수 분포 (이탈 강도 판단)
SELECT
  session_event_cnt,
  COUNT(*) AS sessions
FROM (
  SELECT
    session_id,
    COUNT(*) AS session_event_cnt
  FROM hackle_events
  GROUP BY session_id
) t
GROUP BY session_event_cnt
ORDER BY session_event_cnt;