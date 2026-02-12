-- accounts_paymenthistory
USE docker_mysql;

SELECT * 
FROM accounts_paymenthistory
LIMIT 100
;

SELECT DISTINCT productId
FROM accounts_paymenthistory
;

SELECT COUNT(*)
FROM accounts_paymenthistory
;

SELECT productId,
    COUNT(*) AS ROW_COUNT
FROM accounts_paymenthistory
GROUP BY productId
ORDER BY 2 
;

SELECT phone_type, COUNT(*) AS type_count
FROM accounts_paymenthistory
GROUP BY 1
;

SELECT 
    payment_count,
    COUNT(*) AS user_count
FROM (
    SELECT 
        user_id,
        COUNT(*) AS payment_count
    FROM accounts_paymenthistory
    GROUP BY user_id
) t
GROUP BY payment_count
ORDER BY payment_count;

SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS payment_count
FROM accounts_paymenthistory
GROUP BY month
ORDER BY month;

SELECT 
    phone_type,
    productId,
    COUNT(*) AS purchase_count
FROM accounts_paymenthistory
GROUP BY phone_type, productId
ORDER BY phone_type, purchase_count DESC;

WITH first_payment AS (
    SELECT 
        user_id,
        productId,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY created_at
        ) AS rn
    FROM accounts_paymenthistory
)
SELECT 
    productId,
    COUNT(*) AS first_purchase_count
FROM first_payment
WHERE rn = 1
GROUP BY productId
ORDER BY first_purchase_count DESC;

SELECT 
    AVG(DATEDIFF(second_date, first_date))
FROM (
    SELECT 
        user_id,
        MIN(created_at) AS first_date,
        MAX(CASE WHEN rn = 2 THEN created_at END) AS second_date
    FROM (
        SELECT 
            user_id,
            created_at,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) rn
        FROM accounts_paymenthistory
    ) t
    GROUP BY user_id
) t2
WHERE second_date IS NOT NULL;