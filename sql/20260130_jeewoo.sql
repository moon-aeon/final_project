-- hackle_events 스키마 다시 확인
DESCRIBE hackle_events;

-- event_datetime 과 전체 이벤트간의 편차 없음 == NUll 없음 
SELECT
  COUNT(*) AS total_events,
  COUNT(event_datetime) AS events_with_time,
  COUNT(*) - COUNT(event_datetime) AS events_without_time
FROM hackle_events;

-- hackle_events 기간 동안의 이벤트 수 카운트 
SELECT
  DATE(event_datetime) AS dt,
  COUNT(*) AS event_cnt
FROM hackle_events
WHERE event_datetime IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- 기간별 사용자 및 투표 활동 요약
SELECT 
    CASE 
        WHEN created_at BETWEEN '2023-04-01' AND '2023-06-30' THEN '1. Pre-Hackle (4-6월)'
        WHEN created_at BETWEEN '2023-07-18' AND '2023-08-10' THEN '2. Hackle-Period (7/18-8/10)'
        WHEN created_at BETWEEN '2023-09-01' AND '2023-09-30' THEN '3. Post-Hackle (9월)'
        ELSE 'Others'
    END AS period_group,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(*) AS total_votes,
    ROUND(COUNT(*) / COUNT(DISTINCT user_id), 2) AS votes_per_user
FROM accounts_userquestionrecord
WHERE (created_at BETWEEN '2023-04-01' AND '2023-06-30')
   OR (created_at BETWEEN '2023-07-18' AND '2023-08-10')
   OR (created_at BETWEEN '2023-09-01' AND '2023-09-30')
GROUP BY 1
ORDER BY 1
;

-- 유저들이 각 기간별 친구 관계 비교
-- 기간별 신규 친구 요청(네트워크 형성) 얼마나 했나 
SELECT 
    CASE 
        WHEN created_at BETWEEN '2023-04-01' AND '2023-06-30' THEN '1. Pre (4-6월)'
        WHEN created_at BETWEEN '2023-07-18' AND '2023-08-10' THEN '2. Hackle (7/18-8/10)'
        WHEN created_at BETWEEN '2023-09-01' AND '2023-09-30' THEN '3. Post (9월)'
    END AS period,
    -- 총 친구 요청 수
    COUNT(*) AS total_requests,
    -- 요청을 보낸 유저 수
    COUNT(DISTINCT send_user_id) AS unique_senders,
    -- 요청을 받은 유저 수
    COUNT(DISTINCT receive_user_id) AS unique_receivers,
    -- 1인당 평균 보낸 요청 수
    ROUND(COUNT(*) / COUNT(DISTINCT send_user_id), 2) AS requests_per_sender,
    -- 수락(accepted)된 비율 (status 컬럼의 실제 값에 따라 'accepted' 부분을 수정하세요)
    ROUND(SUM(IF(status = 'A', 1, 0)) / COUNT(*) * 100, 2) AS acceptance_rate_pct
FROM accounts_friendrequest
WHERE (created_at BETWEEN '2023-04-01' AND '2023-06-30')
   OR (created_at BETWEEN '2023-07-18' AND '2023-08-10')
   OR (created_at BETWEEN '2023-09-01' AND '2023-09-30')
GROUP BY 1
ORDER BY 1
;

-- 왜 수락율이 0인지 탐색
-- accept 가 아니라 A 였음 (위의 쿼리 수정 완료)
SELECT status, COUNT(*) 
FROM accounts_friendrequest 
GROUP BY status
;

-- 해클 이벤트 기간의 투표 전환율 비교
-- non-sender 보내지 않은 사람 / sender 보낸 사람 수와 비율 평균 

SELECT 
    CASE WHEN f.send_user_id IS NOT NULL THEN 'Sender' ELSE 'Non-Sender' END AS user_group,
    COUNT(DISTINCT h.id) AS user_cnt,
    ROUND(AVG(h.votes_count), 2) AS avg_votes,
    ROUND(AVG(h.friend_count), 2) AS avg_friends_at_event
FROM hackle_events h
LEFT JOIN accounts_friendrequest f 
    ON h.id = f.send_user_id 
    AND f.created_at BETWEEN '2023-07-18' AND '2023-08-10'
GROUP BY 1;

SELECT 
    MIN(created_at),
    MAX(created_at)
FROM polls_question
;

