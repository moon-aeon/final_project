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



-- 26년 1월 29일 작업 
-- 1. 전체 데이터 개수 및 기간 확인 : 11,441,319 | 23년 7월 18일부터 8월 10일까지 
SELECT 
    COUNT(*) AS total_logs,
    MIN(event_datetime) AS start_date,
    MAX(event_datetime) AS end_date
FROM hackle_events
;

-- 2. 가장 많이 발생하는 이벤트(event_key) TOP 10
SELECT 
    event_key, 
    COUNT(*) AS event_count
FROM hackle_events
GROUP BY event_key
ORDER BY event_count DESC
LIMIT 10;

-- 특정 이벤트가 발생했을 때 사용자의 평균 지표(친구 수, 하트 잔액 등) 확인
-- WHERE 자리에 분석하고 싶은 event_key를 넣자! 
-- 이건 일단 조금 미루기(26.01.29 오후 1:00 기준)
SELECT 
    event_key,
    COUNT(DISTINCT session_id) AS unique_users, -- 참여 유저 수
    AVG(friend_count) AS avg_friends,          -- 평균 친구 수
    AVG(heart_balance) AS avg_hearts,          -- 평균 잔여 하트
    COUNT(question_id) AS total_questions      -- 발생한 총 질문 수
FROM hackle_events
WHERE event_key = 'view_lab_tap'
GROUP BY event_key;

-- 어떤 이벤트가 있는지 event_key 목록 뽑아보기 
SELECT 
    event_key, 
    COUNT(*) AS total_count, -- 발생 횟수
    COUNT(DISTINCT session_id) AS user_count, -- 얼마나 많은 유저가 수행했는지
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hackle_events), 2) AS percentage -- 전체 중 비중
FROM hackle_events
GROUP BY event_key
ORDER BY total_count DESC;

