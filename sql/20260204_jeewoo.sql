-- 어제 공유한 데이터 중 탈퇴자의 양상이 조금 달랐다고 확인했는데
-- 한번 찾아보자 오늘은 탈퇴자에 대한 데이터 찾기 ㄷㄷ

-- 탈퇴자 월별 분포 및 사유 분석
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS withdraw_month,
    COUNT(id) AS withdraw_count,
    -- 가장 빈번한 탈퇴 사유 TOP 1을 확인하기 위한 예시
    GROUP_CONCAT(DISTINCT reason ORDER BY reason DESC SEPARATOR ' | ') AS reason_list
FROM accounts_userwithdraw
GROUP BY withdraw_month
ORDER BY withdraw_month;

-- 23년 5월에 탈퇴한 사람들의 탈퇴사유 
SELECT 
    reason, 
    COUNT(id) AS reason_count,
    ROUND(COUNT(id) * 100.0 / (SELECT COUNT(*) FROM accounts_userwithdraw WHERE DATE_FORMAT(created_at, '%Y-%m') = '2023-05'), 2) AS percentage
FROM accounts_userwithdraw
WHERE DATE_FORMAT(created_at, '%Y-%m') = '2023-05'
GROUP BY reason
ORDER BY reason_count DESC;

SHOW COLUMNS FROM accounts_user;

-- 5월 일자별 탈퇴 
SELECT 
    DATE(created_at) AS withdraw_date,
    COUNT(id) AS etc_reason_count
FROM accounts_userwithdraw
WHERE created_at BETWEEN '2023-05-01' AND '2023-05-31'
  AND reason = '기타 이유'
GROUP BY withdraw_date
ORDER BY withdraw_date;

-- 기타 이유 탈퇴자의 활동 분석
    -- 자꾸 오류가 나 아오!!!!
SELECT 
    -- 투표를 한 번도 못 받은 유저 수 (소외감 지표)
    SUM(CASE WHEN U.pending_votes = 0 THEN 1 ELSE 0 END) AS zero_vote_users,
    
    -- 평균 잔여 포인트 (매몰 비용 지표)
    AVG(U.point) AS avg_points,
    
    -- 고액 포인트(4,000점 이상) 보유 탈퇴자 수
    SUM(CASE WHEN U.point >= 4000 THEN 1 ELSE 0 END) AS high_point_leavers,
    
    -- 총 분석 대상자 수
    COUNT(U.firebase_uid) AS total_analyzed
    
FROM accounts_user U
INNER JOIN accounts_userwithdraw W ON U.firebase_uid = W.user_id
WHERE W.created_at >= '2023-05-01' AND W.created_at < '2023-06-01'
  AND W.reason = '기타 이유';


SELECT COUNT(status)
FROM accounts_userquestionrecord
WHERE status = 'I'
;

/* 데이터 정상성 확인: 6월 데이터와 비교 */
    -- 아무것도 안나옴, 쿼리 이상 이슈
SELECT 
    DATE(created_at) AS dt,
    COUNT(*) AS raw_vote_count,
    COUNT(DISTINCT user_id) AS unique_voters
FROM 
    accounts_userquestionrecord
WHERE 
    created_at >= '2024-06-01' AND created_at < '2024-06-10'
GROUP BY 
    DATE(created_at)
ORDER BY 
    dt;

SELECT * FROM accounts_userquestionrecord;

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
    created_at >= '2023-05-01' AND created_at < '2023-06-01'
GROUP BY 
    DATE(created_at)
ORDER BY 
    dt;

-- 5월 투표-결제 전환 효율 
SELECT 
    v_data.dt,
    v_data.total_votes,
    v_data.hint_opens,
    IFNULL(p_data.actual_payments, 0) AS actual_payments,
    -- 투표 1,000건당 결제 건수 (전환 효율)
    ROUND(IFNULL(p_data.actual_payments, 0) * 1000.0 / v_data.total_votes, 2) AS pay_per_1k_votes
FROM (
    -- 1. 일자별 투표 데이터 집계
    SELECT 
        DATE(created_at) AS dt,
        COUNT(*) AS total_votes,
        SUM(CASE WHEN status = 'I' THEN 1 ELSE 0 END) AS hint_opens
    FROM accounts_userquestionrecord
    WHERE created_at >= '2023-05-01' AND created_at < '2023-06-01'
    GROUP BY DATE(created_at)
) v_data
LEFT JOIN (
    -- 2. 일자별 결제 데이터 집계
    SELECT 
        DATE(created_at) AS dt,
        COUNT(*) AS actual_payments
    FROM accounts_paymenthistory
    WHERE created_at >= '2023-05-01' AND created_at < '2023-06-01'
    GROUP BY DATE(created_at)
) p_data ON v_data.dt = p_data.dt
ORDER BY v_data.dt;