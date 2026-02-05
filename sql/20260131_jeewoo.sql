-- 학교별 가입자 수 및 활성도 체크
-- 2023년 4월 ~ 6월 피크 시점의 학교별 분석 
SELECT 
    s.id AS school_id,
    s.address,
    COUNT(DISTINCT u.id) AS total_users,
    COUNT(CASE WHEN u.created_at BETWEEN '2023-04-01' AND '2023-06-30' THEN 1 END) AS peak_period_new_users,
    AVG(u.point) AS avg_point_balance
FROM accounts_school s
JOIN accounts_user u ON s.id = u.group_id -- group_id가 school_id와 매칭되는지 확인 필요
GROUP BY 1, 2
ORDER BY peak_period_new_users DESC
LIMIT 10;

-- 이탈 원인 : 소외감?
WITH candidate_counts AS (
    SELECT user_id, COUNT(*) as appeared_count
    FROM polls_usercandidate
    GROUP BY user_id
),
chosen_counts AS (
    SELECT chosen_user_id as user_id, COUNT(*) as chosen_count
    FROM accounts_userquestionrecord
    GROUP BY chosen_user_id
)
SELECT 
    u.id AS user_id,
    COALESCE(c.appeared_count, 0) AS appeared_count,
    COALESCE(ch.chosen_count, 0) AS chosen_count,
    CASE WHEN COALESCE(c.appeared_count, 0) = 0 THEN 0 
         ELSE ROUND(CAST(COALESCE(ch.chosen_count, 0) AS FLOAT) / c.appeared_count, 4) 
    END AS selection_rate
FROM accounts_user u
LEFT JOIN candidate_counts c ON u.id = c.user_id
LEFT JOIN chosen_counts ch ON u.id = ch.user_id
WHERE u.created_at <= '2024-05-01'
ORDER BY selection_rate DESC;

-- 이탈 원인 : 신고 및 차단 (피로도)
-- 신고 및 차단 경험 유저의 활동성 변화
SELECT 
    u.id AS user_id,
    u.report_count,
    COUNT(DISTINCT b.id) AS block_count,
    COUNT(DISTINCT r.id) AS report_sent_count
FROM accounts_user u
LEFT JOIN accounts_blockrecord b ON u.id = b.user_id
LEFT JOIN accounts_timelinereport r ON u.id = r.user_id
GROUP BY 1, 2
HAVING u.report_count > 0 OR block_count > 0;

-- hackle 연동 세션과 유저 아이디 매핑 
/* 유저별 질문 시작 및 완료 수 (Hackle) */
SELECT 
    p.user_id,
    COUNT(CASE WHEN e.event_key = 'click_question_start' THEN 1 END) AS start_count,
    COUNT(CASE WHEN e.event_key = 'complete_question' THEN 1 END) AS complete_count,
    COUNT(CASE WHEN e.event_key = 'complete_purchase' THEN 1 END) AS purchase_count
FROM hackle_events e
JOIN hackle_properties p ON e.session_id = p.session_id -- session_id로 유저 식별
WHERE e.event_datetime BETWEEN '2023-07-18' AND '2023-08-10'
GROUP BY 1;