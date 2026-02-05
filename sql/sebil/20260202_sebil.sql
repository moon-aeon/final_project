------------------------------------------------ 원인 탐색 ---------------------------------------------
DESCRIBE accounts_userwithdraw;

SELECT COUNT(*) FROM accounts_userwithdraw;    --70764

SELECT DISTINCT(COUNT(id)) FROM accounts_userwithdraw;     --70764

SELECT DISTINCT(id) FROM accounts_userwithdraw;

-------------------- 2023년 4월 이후 이탈 사용자 수

-- 탈퇴에 대한 탐색을 하기 위해 테이블 만들기
CREATE TEMPORARY TABLE churn_users AS
SELECT
    uw.id,
    uw.reason,
    uw.created_at AS withdraw_at
FROM accounts_userwithdraw uw
WHERE uw.created_at >= '2023-04-01' AND uw.created_at <= '2023-08-31';

--DROP TEMPORARY TABLE churn_users;

SELECT
    DATE_FORMAT(withdraw_at, '%Y-%m') AS ym,
    COUNT(*) AS churn_cnt
FROM churn_users
GROUP BY ym
ORDER BY ym;

-- 2023-04	2397
-- 2023-05	44845 ***
-- 2023-06	9642
-- 2023-07	4811
-- 2023-08	2254

-- 비교를 위한 활성(이탈률 낮은) 코호트 
CREATE TEMPORARY TABLE active_users AS
SELECT
    u.id AS user_id,
    u.created_at,
    u.gender,
    u.group_id,
    u.point,
    u.friend_id_list,
    u.ban_status
FROM accounts_user u
LEFT JOIN accounts_userwithdraw uw
    ON u.id = uw.id
WHERE uw.id IS NULL
  AND u.created_at >= '2023-04-01' AND u.created_at <= '2023-08-31';

-- 탈퇴한 고객 vs 활성화한 고객
CREATE TEMPORARY TABLE churn_features AS        -- 탈퇴한 고객 파생 테이블
SELECT
    u.id AS user_id,
    'churn' AS label,
    u.gender,
    u.group_id,
    u.point,
    JSON_LENGTH(u.friend_id_list) AS friend_cnt,
    u.ban_status,
    cu.withdraw_at
FROM accounts_user u
JOIN churn_users cu ON u.id = cu.id;

-- 활성화한 고객 파생 테이블
CREATE TEMPORARY TABLE active_features AS
SELECT
    a.user_id,
    'active' AS label,
    u.gender,
    u.group_id,
    u.point,
    JSON_LENGTH(u.friend_id_list) AS friend_cnt,
    u.ban_status,
    NULL AS withdraw_at
FROM active_users a
JOIN accounts_user u ON a.user_id = u.id;

-- 테이블 합치기
CREATE TEMPORARY TABLE user_features AS
SELECT * FROM churn_features
UNION ALL
SELECT * FROM active_features;

-- 탈퇴 여부에 따른 평균 친구 수 및 포인트 (특히 5월 가입 또는 5월 탈퇴자에 초점)
SELECT
    label,
    AVG(friend_cnt) AS avg_friend_cnt,
    AVG(point) AS avg_point,
    SUM(CASE WHEN ban_status IS NOT NULL AND ban_status <> '' THEN 1 ELSE 0 END) AS flagged_cnt,
    COUNT(*) AS users
FROM user_features
GROUP BY label;

-- active -- avg_friend_count: 53.5322 -- avg_point: 1738.4795 -- flagged_count: 673665 -- users: 673665

----------------------------------------------------------------------------
-- 이탈 전 마지막으로 확인된 친구 수와 하트 잔액
CREATE TEMPORARY TABLE churn_session_stats AS
SELECT
    he.id,
    MAX(NULLIF(he.friend_count, '')) AS last_friend_cnt,
    MAX(CAST(NULLIF(he.friend_count, '') AS SIGNED)) AS last_heart_balance
FROM hackle_events he
JOIN churn_users cu
  ON he.id = cu.id
 AND he.event_datetime < cu.withdraw_at
GROUP BY he.id;



