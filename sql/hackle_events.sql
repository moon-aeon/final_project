DESCRIBE hackle_events;

-- count: 11441319
SELECT COUNT(*) AS total_rows
FROM hackle_events;

-- NULL 값: question_id_null: 10991835개, 남어지 컬럼은 0
SELECT
  SUM(event_id IS NULL) AS event_id_null,
  SUM(event_datetime IS NULL) AS event_datetime_null,
  SUM(event_key IS NULL) AS event_key_null,
  SUM(session_id IS NULL) AS session_id_null,
  SUM(id IS NULL) AS user_id_null,
  SUM(question_id IS NULL) AS question_id_null
FROM hackle_events;

-- 로그 기간 2023-07-18 00:00:00 ~ 2023-08-10 23:59:59
SELECT
  MIN(event_datetime) AS first_event,
  MAX(event_datetime) AS last_event
FROM hackle_events;

--일별 이벤트 수: event_count 2023-08-06일 806121
SELECT
  DATE(event_datetime) AS event_date,
  COUNT(*) AS event_count
FROM hackle_events
GROUP BY DATE(event_datetime)
ORDER BY event_count DESC;

-- 이벤트 종류
SELECT
  event_key,
  COUNT(*) AS event_count
FROM hackle_events
GROUP BY event_key
ORDER BY event_count DESC;

--event_key별 고유 사용자 수
SELECT
  event_key,
  COUNT(DISTINCT id) AS unique_users
FROM hackle_events
GROUP BY event_key
ORDER BY unique_users DESC;


-- page_name 분포
SELECT
  page_name,
  COUNT(*) AS event_count
FROM hackle_events
GROUP BY page_name
ORDER BY event_count DESC;

-- item_name 분포
SELECT
  item_name,
  COUNT(*) AS event_count
FROM hackle_events
GROUP BY item_name
ORDER BY event_count DESC;

-- 기본 통계
SELECT
  MIN(friend_count) AS min_friend,
  MAX(friend_count) AS max_friend,
  AVG(friend_count) AS avg_friend,

  MIN(votes_count) AS min_votes,
  MAX(votes_count) AS max_votes,
  AVG(votes_count) AS avg_votes,

  MIN(heart_balance) AS min_heart,
  MAX(heart_balance) AS max_heart,
  AVG(heart_balance) AS avg_heart
FROM hackle_events;

-- 음수 값 없음
SELECT *
FROM hackle_events
WHERE friend_count < 0
   OR votes_count < 0
   OR heart_balance < 0;

-- 질문별 참여 사용자 수
SELECT
  question_id,
  COUNT(DISTINCT id) AS unique_users
FROM hackle_events
GROUP BY question_id
ORDER BY unique_users DESC;

--event_key별 세션 수
SELECT
  event_key,
  COUNT(DISTINCT session_id) AS sessions
FROM hackle_events
GROUP BY event_key
ORDER BY sessions DESC;
