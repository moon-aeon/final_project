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