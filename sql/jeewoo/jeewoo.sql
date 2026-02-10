-- 19번 polls_questionreport 테이블에서 reason 질문의 비율 보기(고유 / 고유 아닌 값)
SELECT
  reason,
  COUNT(question_id) AS reported_question_cnt,
  ROUND(
    COUNT(question_id) * 100.0
    / SUM(COUNT(question_id)) OVER (),
    2
  ) AS ratio_pct
FROM polls_questionreport
GROUP BY reason
ORDER BY reported_question_cnt DESC;

-- 20번 polls_questionset 테이블에서 question_piece_id_list 에 빈 값이 있는지 체크 
SELECT
  user_id,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN question_piece_id_list IS NULL THEN 1 ELSE 0 END) AS null_cnt,
  SUM(
    CASE
      WHEN question_piece_id_list IS NOT NULL
       AND JSON_LENGTH(question_piece_id_list) = 0
      THEN 1 ELSE 0
    END
  ) AS empty_list_cnt
FROM polls_questionset
GROUP BY user_id
HAVING null_cnt > 0 OR empty_list_cnt > 0
;

SELECT
  COUNT(*) AS suspicious_rows
FROM polls_questionset
WHERE
  question_piece_id_list IS NULL
  OR JSON_LENGTH(question_piece_id_list) = 0
  OR JSON_CONTAINS(question_piece_id_list, 'null');

-- status C,O,F 각각의 수 체크 
SELECT 
    status,
    COUNT(*) AS cnt
FROM polls_questionset
WHERE status IN ('C', 'O', 'F')
GROUP BY status
;

-- hackle_properties 관련 쿼리문~~~ 
-- 고유값 체크
SELECT
    COUNT(DISTINCT (session_id))
FROM hackle_properties
;

-- null 파악해보기(session_id, user_id, device_id...)
SELECT
  SUM(CASE WHEN session_id IS NULL THEN 1 ELSE 0 END) AS session_id_null,
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS user_id_null,
  SUM(CASE WHEN device_id IS NULL THEN 1 ELSE 0 END) AS device_id_null,
  SUM(CASE WHEN language IS NULL THEN 1 ELSE 0 END) AS language_null,
  SUM(CASE WHEN osname IS NULL THEN 1 ELSE 0 END) AS osname_null,
  SUM(CASE WHEN osversion IS NULL THEN 1 ELSE 0 END) AS osversion_null,
  SUM(CASE WHEN versionname IS NULL THEN 1 ELSE 0 END) AS versionname_null
FROM hackle_properties;

-- 사용자/ 세션 구조 파악
    -- 78197 
    -- 이하 13 ~ 1 사이 
SELECT
    COUNT(DISTINCT session_id) AS session_cnt
FROM hackle_properties
GROUP BY user_id
ORDER BY session_cnt DESC
;

-- 유저당 세션수가 7만건이 정상은 아니겠지?
-- 해당 유저 아이디 확인 : 공백 
SELECT
  user_id,
  COUNT(DISTINCT session_id) AS session_cnt
FROM hackle_properties
GROUP BY user_id
ORDER BY session_cnt DESC
LIMIT 10;

-- 공백 확인 
    -- user_id : 82,255
SELECT
  COUNT(*) AS space_user_id_cnt
FROM hackle_properties
WHERE TRIM(user_id) = '';

-- 유저 아이디가 "null" 문자열인 경우
SELECT
  user_id,
  COUNT(*)
FROM hackle_properties
WHERE LOWER(user_id) IN ('null', 'none', 'undefined')
GROUP BY user_id;

-- 유저 아이디 실제 값 시각화 
-- hex 가 비어있는 값이 82,255
SELECT
  user_id,
  LENGTH(user_id) AS len,
  HEX(user_id) AS hex_value,
  COUNT(*) AS cnt
FROM hackle_properties
GROUP BY user_id
ORDER BY cnt DESC
LIMIT 5;

-- device_properties 테이블 뜯어보기 
SELECT
  COUNT(DISTINCT device_id) AS devices,
  COUNT(DISTINCT device_model) AS models,
  COUNT(DISTINCT device_vendor) AS vendors
FROM device_properties
;

-- device_vendor 제조사 리스트 보기
SELECT
    DISTINCT(device_vendor)
FROM device_properties;

-- 제조사 비율 
SELECT
  device_vendor,
  COUNT(DISTINCT device_id) AS devices,
  ROUND(
    COUNT(DISTINCT device_id) * 100.0
    / SUM(COUNT(DISTINCT device_id)) OVER (), 2
  ) AS ratio_pct
FROM device_properties
GROUP BY device_vendor
ORDER BY devices DESC;

-- 롱테일 구조확인(모델별 누적 커버리지)
-- 각각 159
WITH model_cnt AS (
  SELECT
    device_model,
    COUNT(DISTINCT device_id) AS cnt
  FROM device_properties
  GROUP BY device_model
)
SELECT
  COUNT(*) AS model_cnt,
  SUM(cnt) AS device_cnt
FROM model_cnt
WHERE cnt = 1;

-- hackle_properties 와 조인해서 vendor 활성 세션 보기
SELECT
  d.device_vendor,
  COUNT(DISTINCT h.session_id) AS sessions,
  COUNT(DISTINCT h.device_id) AS devices
FROM hackle_properties h
JOIN device_properties d
  ON h.device_id = d.device_id
GROUP BY d.device_vendor
ORDER BY sessions DESC;

-- 2회 이상 재방문 비율 
-- 0.99007 : 디바이스 기준 분석 결과, 전체 사용자 중 99.0%가 단일 세션만 기록하였고, 
-- 2회 이상 재방문한 디바이스는 약 1% 미만에 그쳤다.
SELECT
  COUNT(DISTINCT CASE WHEN session_cnt = 1 THEN device_id END) * 1.0
  / COUNT(DISTINCT device_id) AS one_session_ratio
FROM (
  SELECT
    device_id,
    COUNT(DISTINCT session_id) AS session_cnt
  FROM hackle_properties
  GROUP BY device_id
) t;

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

