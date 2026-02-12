SELECT 
    DATE(created_at) AS dt,
    -- 1. 전체 투표 수 (서비스 활성도)
    COUNT(*) AS total_votes,
    -- 2. 초성 열람 수 (유저의 호기심/결제 동기)
    SUM(CASE WHEN status = 'I' THEN 1 ELSE 0 END) AS hint_opened,
    -- 3. 답장 수 (유저 간 상호작용)
    SUM(CASE WHEN answer_status != 'N' THEN 1 ELSE 0 END) AS replied_count,
    -- 4. 유니크 유저 수 (실제 활동 인원)
    COUNT(DISTINCT user_id) AS unique_voters,
    -- 5. 투표당 초성 열람률 (수익화 건강도)
    ROUND(SUM(CASE WHEN status = 'I' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS hint_open_rate
FROM 
    accounts_userquestionrecord
WHERE 
    created_at >= '2023-03-01' AND created_at < '2024-12-31'
GROUP BY 
    DATE(created_at)
ORDER BY 
    dt;

-- 5월 유저들(투표를 한 사람, 안한시림. 투표를 받은 사람, 아무 활동도 없는 사람)의 특징을 기능별로 시각화 정리 

-- 우선 상품 구매 실패 기록 테이블은 어떻게 생겼어?
SELECT *
FROM accounts_failpaymenthistory
LIMIT 20;

-- phone_type 의 유니크 값 
SELECT DISTINCT(phone_type)
FROM accounts_failpaymenthistory;

-- productId 의 유니크 값
SELECT DISTINCT(productId)
FROM accounts_failpaymenthistory;

-- accounts_friendrequest 테이블 전체 값 보기
SELECT * FROM accounts_friendrequest;

-- 2023년 5월 결제 실패 유저 특징
SELECT
  DATE(created_at) AS dt,
  phone_type,
  productId,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) AS fail_cnt
FROM accounts_failpaymenthistory
WHERE created_at >= '2023-05-01'
  AND created_at < '2023-06-01'
GROUP BY 1, 2, 3
ORDER BY dt, phone_type, productId;


-- 5월 결제 실패 유저의 productId 별 실패 횟수 분포 
SELECT
  productId,
  COUNT(*) AS total_fail_cnt,
  COUNT(DISTINCT user_id) AS unique_users,
  ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT user_id), 2) AS fail_per_user
FROM accounts_failpaymenthistory
WHERE created_at >= '2023-05-01'
  AND created_at < '2023-06-01'
GROUP BY 1
ORDER BY total_fail_cnt DESC;

-- 5월 친구 요청 전체 현황(요청, 수락, 거절)
SELECT
  DATE(created_at) AS dt,
  status,
  COUNT(*) AS request_cnt,
  COUNT(DISTINCT send_user_id) AS send_users,
  COUNT(DISTINCT receive_user_id) AS receive_users
FROM accounts_friendrequest
WHERE created_at >= '2023-05-01'
  AND created_at < '2023-06-01'
GROUP BY 1, 2
ORDER BY dt, status;

-- 5월 친구 요청 활동 (받은사람 / 보낸사람)
WITH senders AS (
  SELECT DISTINCT send_user_id AS user_id
  FROM accounts_friendrequest
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
),
receivers AS (
  SELECT DISTINCT receive_user_id AS user_id
  FROM accounts_friendrequest
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
)
SELECT
  CASE
    WHEN s.user_id IS NOT NULL AND r.user_id IS NOT NULL THEN 'both_send_and_receive'
    WHEN s.user_id IS NOT NULL THEN 'only_send'
    WHEN r.user_id IS NOT NULL THEN 'only_receive'
    ELSE 'none'
  END AS user_type,
  COUNT(*) AS users
FROM (
  SELECT user_id FROM senders
  UNION
  SELECT user_id FROM receivers
) u
LEFT JOIN senders s ON u.user_id = s.user_id
LEFT JOIN receivers r ON u.user_id = r.user_id
GROUP BY 1
ORDER BY users DESC;

-- 친구 요청 수락율 (5월)
SELECT
  COUNT(*) AS total_requests,
  SUM(CASE WHEN status = 'A' THEN 1 ELSE 0 END) AS accepted_requests,
  ROUND(SUM(CASE WHEN status = 'A' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS accept_rate_pct
FROM accounts_friendrequest
WHERE created_at >= '2023-05-01'
  AND created_at < '2023-06-01';

-- 결제 실패 유저와 친구요청유저간의 공통된 교집합 분석 
WITH payfail_users AS (
  SELECT DISTINCT user_id
  FROM accounts_failpaymenthistory
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
),
friend_users AS (
  SELECT DISTINCT send_user_id AS user_id
  FROM accounts_friendrequest
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
  UNION
  SELECT DISTINCT receive_user_id AS user_id
  FROM accounts_friendrequest
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
)
SELECT
  CASE
    WHEN p.user_id IS NOT NULL AND f.user_id IS NOT NULL THEN 'payfail_and_friend'
    WHEN p.user_id IS NOT NULL THEN 'only_payfail'
    WHEN f.user_id IS NOT NULL THEN 'only_friend'
    ELSE 'none'
  END AS segment,
  COUNT(*) AS users
FROM (
  SELECT user_id FROM payfail_users
  UNION
  SELECT user_id FROM friend_users
) u
LEFT JOIN payfail_users p ON u.user_id = p.user_id
LEFT JOIN friend_users f ON u.user_id = f.user_id
GROUP BY 1
ORDER BY users DESC;

-- 결제 실패 유저들의 친구 요청 활동성
WITH payfail_users AS (
  SELECT DISTINCT user_id
  FROM accounts_failpaymenthistory
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
)
SELECT
  p.user_id,
  COUNT(fr.send_user_id) AS sent_requests,
  COUNT(fr.receive_user_id) AS received_requests,
  SUM(CASE WHEN fr.status = 'A' THEN 1 ELSE 0 END) AS accepted_cnt
FROM payfail_users p
LEFT JOIN accounts_friendrequest fr
  ON (p.user_id = fr.send_user_id OR p.user_id = fr.receive_user_id)
  AND fr.created_at >= '2023-05-01'
  AND fr.created_at < '2023-06-01'
GROUP BY p.user_id
ORDER BY sent_requests DESC, received_requests DESC;

-- 5월 친구 요청 활동(보낸사람 / 받은 사람) -> 일자별로 확인 
WITH senders AS (
  SELECT DISTINCT
    DATE(created_at) AS dt,
    send_user_id AS user_id
  FROM accounts_friendrequest
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
),
receivers AS (
  SELECT DISTINCT
    DATE(created_at) AS dt,
    receive_user_id AS user_id
  FROM accounts_friendrequest
  WHERE created_at >= '2023-05-01'
    AND created_at < '2023-06-01'
),
all_users AS (
  SELECT dt, user_id FROM senders
  UNION
  SELECT dt, user_id FROM receivers
)
SELECT
  a.dt,
  CASE
    WHEN s.user_id IS NOT NULL AND r.user_id IS NOT NULL THEN 'both_send_and_receive'
    WHEN s.user_id IS NOT NULL THEN 'only_send'
    WHEN r.user_id IS NOT NULL THEN 'only_receive'
    ELSE 'none'
  END AS user_type,
  COUNT(DISTINCT a.user_id) AS users
FROM all_users a
LEFT JOIN senders s
  ON a.dt = s.dt AND a.user_id = s.user_id
LEFT JOIN receivers r
  ON a.dt = r.dt AND a.user_id = r.user_id
GROUP BY a.dt, user_type
ORDER BY a.dt, users DESC;

