-- accounts_paymenthistory

DESCRIBE accounts_paymenthistory; -- user_id, productId, phone_type, created_at
SELECT * FROM accounts_paymenthistory LIMIT 5;

SELECT
    MIN(created_at),            
    MAX(created_at)
FROM accounts_paymenthistory;       -- 2023-05-13 21:28:34	2024-05-08 14:12:45

SELECT
    MIN(created_at),
    MAX(created_at)
FROM accounts_userquestionrecord;   -- 2023-04-28 12:27:49	2024-05-08 01:36:18

SELECT
    MIN(created_at),
    MAX(created_at)
FROM polls_questionpiece;           -- 2023-04-28 12:27:22	2024-05-07 11:32:30

------------------
CREATE 
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ap.user_id) AS unique_payers,
    COUNT(DISTINCT auqr.user_id) AS unique_questioners,
    COUNT(DISTINCT auqr.question_id) AS unique_questions,
    COUNT(DISTINCT productId) AS unique_products
FROM accounts_paymenthistory ap
LEFT JOIN accounts_userquestionrecord auqr ON ap.user_id = auqr.user_id
WHERE ap.created_at >= '2023-05-13' AND ap.created_at <= '2024-05-07'
  AND (auqr.created_at >= '2023-05-13' AND auqr.created_at <= '2024-05-07' OR auqr.user_id IS NULL);

--
SELECT 
    COUNT(*) AS total_payments,
    COUNT(DISTINCT user_id) AS unique_payers,
    COUNT(DISTINCT productId) AS unique_products,
    ROUND(100.0 * COUNT(DISTINCT user_id) / COUNT(*), 2) AS unique_payer_pct
FROM accounts_paymenthistory
WHERE created_at >= '2023-05-13' AND created_at <= '2024-05-07';


--
SELECT 
    purchase_freq_bucket,
    COUNT(DISTINCT user_id) AS users,
    AVG(payments_per_user) AS avg_payments,
    SUM(payments_per_user) AS total_payments
FROM (
    SELECT 
        user_id,
        COUNT(*) AS payments_per_user,
        CASE 
            WHEN COUNT(*) = 1 THEN 'One-time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Repeat'
            ELSE 'Heavy'
        END AS purchase_freq_bucket
    FROM accounts_paymenthistory
    WHERE created_at >= '2023-05-13' AND created_at <= '2024-05-07'
    GROUP BY user_id
) t
GROUP BY 1
ORDER BY users DESC;

---
SELECT 
    DATE_FORMAT(created_at, '%Y-%m-%W') AS week_period,
    COUNT(*) AS payments,
    COUNT(DISTINCT user_id) AS buyers
FROM accounts_paymenthistory
WHERE created_at >= '2023-05-13' AND created_at <= '2024-05-07'
GROUP BY 1
ORDER BY 1;


--
WITH buyer_cohort AS (
    SELECT 
        user_id,
        CASE 
            WHEN COUNT(*) = 1 THEN 'One-time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Repeat'
            ELSE 'Heavy'
        END AS purchase_freq_bucket
    FROM accounts_paymenthistory
    WHERE created_at >= '2023-05-13' AND created_at <= '2024-05-07'
    GROUP BY user_id
),
payments_with_questions AS (
    SELECT 
        bc.purchase_freq_bucket,
        ap.user_id,
        COUNT(auqr.status) > 0 AS has_question
    FROM buyer_cohort bc
    LEFT JOIN accounts_paymenthistory ap ON bc.user_id = ap.user_id
    LEFT JOIN accounts_userquestionrecord auqr ON ap.user_id = auqr.user_id
    WHERE ap.created_at >= '2023-05-13' AND ap.created_at <= '2024-05-07'
      AND (auqr.created_at >= '2023-05-13' AND auqr.created_at <= '2024-05-07' OR auqr.user_id IS NULL)
    GROUP BY bc.purchase_freq_bucket, ap.user_id
)
SELECT 
    purchase_freq_bucket,
    COUNT(DISTINCT user_id) AS payers,
    COUNT(DISTINCT CASE WHEN has_question THEN user_id END) AS questioners,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN has_question THEN user_id END) / COUNT(DISTINCT user_id), 2) AS question_rate_pct
FROM payments_with_questions
GROUP BY 1
ORDER BY payers DESC;

-------------------------------------------------------------------------------------------------------------
------------------------accounts_userquestionrecord-----------------------------------------------------

DESCRIBE accounts_userquestionrecord;

SELECT * FROM accounts_userquestionrecord LIMIT 5;

