select * from polls_questionreport;

select * from polls_questionset
limit 10;

select DISTINCT(question_piece_id_list) from polls_questionset;

select * from polls_usercandidate limit 10;

select * from hackle_properties limit 10;

-- 1. 유저별 세션 활동 통합 (hackle_events + hackle_properties)
-- 데이터 출력이 너무 많음 약 33만행 
WITH UserActivity AS (
    SELECT 
        p.user_id,
        e.event_key,
        e.event_datetime,
        e.heart_balance,
        p.osname
    FROM hackle_events e
    JOIN hackle_properties p ON e.session_id = p.session_id
)
-- 2. 유저별 최종 활동일 및 특성 추출
SELECT 
    user_id,
    MAX(event_datetime) AS last_active_day,
    COUNT(event_key) AS total_action_count,
    AVG(heart_balance) AS avg_heart
FROM UserActivity
GROUP BY user_id;

-- 축약해서 일자별로 이탈 흐름 살펴보기
WITH UserActivity AS (
    SELECT 
        p.user_id,
        e.event_datetime
    FROM hackle_events e
    JOIN hackle_properties p ON e.session_id = p.session_id
),
UserSummary AS (
    -- 유저별로 마지막 활동일만 뽑습니다.
    SELECT 
        user_id,
        MAX(event_datetime) AS last_active_day
    FROM UserActivity
    GROUP BY user_id
)
-- 최종 결과: 날짜별로 몇 명이 마지막이었는지 집계
SELECT 
    DATE(last_active_day) AS last_day,
    COUNT(user_id) AS user_count
FROM UserSummary
GROUP BY 1
ORDER BY 1;

-- 32만명 중 7월 20일 이전에 마지막 기록이 있고 그 뒤로 안나타난 사람들은 이탈자 아닐까
WITH UserSummary AS (
    SELECT 
        p.user_id,
        MAX(e.event_datetime) AS last_active_day,
        COUNT(e.event_id) AS total_events,
        AVG(e.heart_balance) AS avg_heart
    FROM hackle_events e
    JOIN hackle_properties p ON e.session_id = p.session_id
    GROUP BY p.user_id
)
SELECT 
    CASE WHEN last_active_day < '2023-08-01' THEN '이탈군(7월중단)' 
         ELSE '유지군(8월활동)' END AS user_group,
    COUNT(user_id) AS user_count,
    AVG(total_events) AS avg_action_per_user,
    AVG(avg_heart) AS avg_heart_balance
FROM UserSummary
GROUP BY 1;

-- 1. session 기반 이벤트 로그 user_id 붙여 전체 데이터 만들기 
-- hackle_properties 와 hackle_events 
SELECT
  hp.user_id,
  he.session_id,
  he.event_id,
  he.event_datetime,
  he.event_key,
  he.page_name,
  he.item_name,
  he.friend_count,
  he.votes_count,
  he.heart_balance,
  he.question_id
FROM hackle_events he
JOIN hackle_properties hp
  ON he.session_id = hp.session_id
WHERE hp.user_id IS NOT NULL
  AND TRIM(hp.user_id) <> ''
;

-- 다시 1 쿼리로 돌아와 user_id 에 세션 아이디가 섞인거 제거 
SELECT
  hp.user_id,
  he.session_id,
  he.event_id,
  he.event_datetime,
  he.event_key,
  he.page_name,
  he.item_name,
  he.friend_count,
  he.votes_count,
  he.heart_balance,
  he.question_id
FROM hackle_events he
JOIN hackle_properties hp
  ON he.session_id = hp.session_id
WHERE hp.user_id IS NOT NULL
  AND TRIM(hp.user_id) <> ''
  AND hp.user_id REGEXP '^[0-9]+$';

-- 비정상적인 user_id 있는지 확인 
-- 잘못된 사용자가 전체 525,350 중 191,259 명 (정상적인 아이디는 334,091)
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN user_id REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) AS valid_user_id,
  SUM(CASE WHEN user_id NOT REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) AS invalid_user_id
FROM hackle_properties;

-- 비정상적인 user_id 샘플 확인
SELECT DISTINCT user_id
FROM hackle_properties
WHERE user_id IS NOT NULL
  AND TRIM(user_id) <> ''
  AND user_id NOT REGEXP '^[0-9]+$'
LIMIT 50;

-- 2. 유저별 처음과 마지막 활동 구하기
-- 전체 행 수 230,853행 
SELECT
  hp.user_id,
  MIN(he.event_datetime) AS first_active_datetime,
  MAX(he.event_datetime) AS last_active_datetime
FROM hackle_events he
JOIN hackle_properties hp
  ON he.session_id = hp.session_id
WHERE hp.user_id IS NOT NULL
  AND TRIM(hp.user_id) <> ''
  AND hp.user_id REGEXP '^[0-9]+$'
GROUP BY hp.user_id;

-- 14일 미활동 (이탈 라벨링)
-- 출력 결과 행수가 너무 많.. 23만개 해클 토나와
WITH max_date AS (
  SELECT MAX(event_datetime) AS max_event_datetime
  FROM hackle_events
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hackle_properties hp
    ON he.session_id = hp.session_id
  WHERE hp.user_id IS NOT NULL
    AND TRIM(hp.user_id) <> ''
    AND hp.user_id REGEXP '^[0-9]+$'
  GROUP BY hp.user_id
)
SELECT
  ula.user_id,
  ula.last_active_datetime,
  CASE
    WHEN ula.last_active_datetime < DATE_SUB((SELECT max_event_datetime FROM max_date), INTERVAL 14 DAY)
    THEN 1 ELSE 0
  END AS is_churn
FROM user_last_active ula;

-- 혹시 중복된거 있는지 찾아보기 

-- DISTINCT user_id 확인 
-- rows_cnt 와 distinct_user 는 같아야함 => 같게 나옴 230,853
WITH max_date AS (
  SELECT MAX(event_datetime) AS max_event_datetime
  FROM hackle_events
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hackle_properties hp
    ON he.session_id = hp.session_id
  WHERE hp.user_id IS NOT NULL
    AND TRIM(hp.user_id) <> ''
    AND hp.user_id REGEXP '^[0-9]+$'
  GROUP BY hp.user_id
)
SELECT
  COUNT(*) AS rows_cnt,
  COUNT(DISTINCT user_id) AS distinct_users
FROM user_last_active;

-- hackle_properties 에서 user_id 중복 보기
-- total_rows = 334091 / distinct_users = 230853 (10만 정도 차이 남 )
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS distinct_users
FROM hackle_properties
WHERE user_id IS NOT NULL
  AND TRIM(user_id) <> ''
  AND user_id REGEXP '^[0-9]+$';

-- hackle_properties 에서 session_id 중복 여부 
-- total_rows = 525,350 | distinct_sessions = 253,616
-- 세션 아이디가 평균 2번 정도 중복 저장 
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT session_id) AS distinct_sessions
FROM hackle_properties;

-- hackle_properties를 session_id 단위로 먼저 중복 제거ㄱㄱ 기본 틀
    WITH hp_clean AS (
    SELECT
        session_id,
        MIN(user_id) AS user_id,
        MIN(language) AS language,
        MIN(osname) AS osname,
        MIN(osversion) AS osversion,
        MIN(versionname) AS versionname,
        MIN(device_id) AS device_id
    FROM hackle_properties
    WHERE user_id IS NOT NULL
        AND TRIM(user_id) <> ''
        AND user_id REGEXP '^[0-9]+$'
    GROUP BY session_id
    )

-- 이탈 라벨링 재진행 
-- is_churn 이 1이면 마지막 날(last_act_datetime) 이후 14일 이상 이벤트 없음  = 이탈 유저 
WITH hp_clean AS (
  SELECT
    session_id,
    MIN(user_id) AS user_id
  FROM hackle_properties
  WHERE user_id IS NOT NULL
    AND TRIM(user_id) <> ''
    AND user_id REGEXP '^[0-9]+$'
  GROUP BY session_id
),
max_date AS (
  SELECT MAX(event_datetime) AS max_event_datetime
  FROM hackle_events
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hp_clean hp
    ON he.session_id = hp.session_id
  GROUP BY hp.user_id
)
SELECT
  ula.user_id,
  ula.last_active_datetime,
  CASE
    WHEN ula.last_active_datetime < DATE_SUB((SELECT max_event_datetime FROM max_date), INTERVAL 14 DAY)
    THEN 1 ELSE 0
  END AS is_churn
FROM user_last_active ula;

-- hackle_events 에서 숫자만 있는 결측치 없는 정상 유저 중 활동 기록이 최소 1번이라도 있는거 체크 
-- 230,802 (분석 가능한 수 = 전체 활동 유저 수)
WITH hp_clean AS (
  SELECT
    session_id,
    MIN(user_id) AS user_id
  FROM hackle_properties
  WHERE user_id IS NOT NULL
    AND TRIM(user_id) <> ''
    AND user_id REGEXP '^[0-9]+$'
  GROUP BY session_id
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hp_clean hp
    ON he.session_id = hp.session_id
  GROUP BY hp.user_id
)
SELECT
  COUNT(*) AS users
FROM user_last_active;

-- 마지막 활동일 이후 14일 이상 움직임 없는 유저 수 카운트 
-- 74,636
WITH hp_clean AS (
  SELECT
    session_id,
    MIN(user_id) AS user_id
  FROM hackle_properties
  WHERE user_id IS NOT NULL
    AND TRIM(user_id) <> ''
    AND user_id REGEXP '^[0-9]+$'
  GROUP BY session_id
),
max_date AS (
  SELECT MAX(event_datetime) AS max_event_datetime
  FROM hackle_events
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hp_clean hp
    ON he.session_id = hp.session_id
  GROUP BY hp.user_id
),
churn_label AS (
  SELECT
    user_id,
    CASE
      WHEN last_active_datetime < DATE_SUB((SELECT max_event_datetime FROM max_date), INTERVAL 14 DAY)
      THEN 1 ELSE 0
    END AS is_churn
  FROM user_last_active
)
SELECT
  COUNT(*) AS churn_users
FROM churn_label
WHERE is_churn = 1;

SELECT * FROM hackle_events;

-- 전체 이탈 유저수와 이탈률 계산 
WITH hp_clean AS (
  SELECT
    session_id,
    MIN(user_id) AS user_id
  FROM hackle_properties
  WHERE user_id IS NOT NULL
    AND TRIM(user_id) <> ''
    AND user_id REGEXP '^[0-9]+$'
  GROUP BY session_id
),
max_date AS (
  SELECT MAX(event_datetime) AS max_event_datetime
  FROM hackle_events
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hp_clean hp
    ON he.session_id = hp.session_id
  GROUP BY hp.user_id
),
churn_label AS (
  SELECT
    user_id,
    last_active_datetime,
    CASE
      WHEN last_active_datetime < DATE_SUB((SELECT max_event_datetime FROM max_date), INTERVAL 14 DAY)
      THEN 1 ELSE 0
    END AS is_churn
  FROM user_last_active
)
SELECT
  COUNT(*) AS total_users,
  SUM(is_churn) AS churn_users,
  COUNT(*) - SUM(is_churn) AS active_users,
  ROUND(SUM(is_churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM churn_label;

-- 이탈 유저가 언제 이탈했나~ == last_active 분포 확인 
WITH hp_clean AS (
  SELECT
    session_id,
    MIN(user_id) AS user_id
  FROM hackle_properties
  WHERE user_id IS NOT NULL
    AND TRIM(user_id) <> ''
    AND user_id REGEXP '^[0-9]+$'
  GROUP BY session_id
),
max_date AS (
  SELECT MAX(event_datetime) AS max_event_datetime
  FROM hackle_events
),
user_last_active AS (
  SELECT
    hp.user_id,
    MAX(he.event_datetime) AS last_active_datetime
  FROM hackle_events he
  JOIN hp_clean hp
    ON he.session_id = hp.session_id
  GROUP BY hp.user_id
),
churn_label AS (
  SELECT
    user_id,
    last_active_datetime,
    CASE
      WHEN last_active_datetime < DATE_SUB((SELECT max_event_datetime FROM max_date), INTERVAL 14 DAY)
      THEN 1 ELSE 0
    END AS is_churn
  FROM user_last_active
)
SELECT
  DATE(last_active_datetime) AS last_active_date,
  COUNT(*) AS churn_users
FROM churn_label
WHERE is_churn = 1
GROUP BY DATE(last_active_datetime)
ORDER BY last_active_date;

-- 민수님 쿼리에서 2개 이상만 보고 싶은거로 출력 
SELECT send_user_id, receive_user_id, COUNT(id) 
FROM accounts_friendrequest 
GROUP BY send_user_id, receive_user_id 
HAVING COUNT(id) > 1
ORDER BY 3 DESC;

-- 서로 보낸 경우를 포함한 중복을 찾을 때 
SELECT 
    LEAST(send_user_id, receive_user_id) as user_a,
    GREATEST(send_user_id, receive_user_id) as user_b,
    COUNT(id) 
FROM accounts_friendrequest 
GROUP BY 1, 2 
HAVING COUNT(id) > 1
ORDER BY 3 DESC;