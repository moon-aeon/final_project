-- 월별 이탈 유저 계산 
WITH last_activity AS (
    SELECT 
        user_id,
        MAX(created_at) AS last_active_date
    FROM accounts_userquestionrecord
    GROUP BY user_id
),
churn_users AS (
    SELECT 
        DATE_FORMAT(last_active_date, '%Y-%m') AS churn_month,
        COUNT(user_id) AS churn_count
    FROM last_activity
    WHERE last_active_date < DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY DATE_FORMAT(last_active_date, '%Y-%m')
)
SELECT * FROM churn_users
ORDER BY churn_month
;