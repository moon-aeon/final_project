-- 월별 활성화 유저 수 구하기
SELECT COUNT(*) FROM accounts_attendance;

WITH aa AS (
    SELECT 
        a.user_id,
        jt.attendance_date AS created_at
    FROM accounts_attendance AS a,
         JSON_TABLE(
             a.attendance_date_list,
             '$[*]' COLUMNS (
                 attendance_date VARCHAR(20) PATH '$'
             )
         ) AS jt
),
af AS (
    SELECT 
        send_user_id AS user_id,
        created_at
    FROM accounts_friendrequest
)
SELECT
    DATE_FORMAT(ua.created_at, '%Y-%m') AS ym,
    COUNT(DISTINCT ua.user_id) AS monthly_active_users
FROM (
    SELECT user_id, created_at FROM accounts_blockrecord
    UNION ALL
    SELECT user_id, created_at FROM accounts_paymenthistory
    UNION ALL
    SELECT user_id, created_at FROM accounts_failpaymenthistory
    UNION ALL
    SELECT user_id, created_at FROM accounts_pointhistory
    UNION ALL
    SELECT user_id, created_at FROM accounts_timelinereport
    UNION ALL
    SELECT user_id, created_at FROM accounts_userquestionrecord
    UNION ALL
    SELECT user_id, created_at FROM event_receipts
    UNION ALL
    SELECT user_id, created_at FROM polls_questionreport
    UNION ALL
    SELECT user_id, created_at FROM aa
    UNION ALL
    SELECT user_id, created_at FROM af
) AS ua
GROUP BY ym;

