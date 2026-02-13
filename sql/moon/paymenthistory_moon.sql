-- Active: 1769563353419@@localhost@3400@docker_mysql
USE docker_mysql;

DESCRIBE accounts_paymenthistory;
-- 1회 결제 유저 vs 재구매 유저: 유저수 + 비율
SELECT
  CASE WHEN pay_cnt = 1 THEN 'one_time' ELSE 'repeat' END AS user_group,
  COUNT(*) AS users,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT user_id) FROM accounts_paymenthistory), 2) AS ratio_pct
FROM (
  SELECT user_id, COUNT(*) AS pay_cnt
  FROM accounts_paymenthistory
  GROUP BY user_id
) t
GROUP BY user_group
ORDER BY users DESC
;

SELECT
  t.productId,
  COUNT(*) AS first_purchase_users,
  ROUND(
    100.0 * COUNT(*) / (SELECT COUNT(DISTINCT user_id) FROM accounts_paymenthistory),
  2) AS ratio_pct
FROM (
  SELECT
    user_id,
    productId,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS rn
  FROM accounts_paymenthistory
) t
WHERE t.rn = 1
GROUP BY t.productId
ORDER BY first_purchase_users DESC
;

-- 첫 결제가 777인 유저 중, 2회 이상 결제한 비율
WITH user_pay AS (
  SELECT
    user_id,
    COUNT(*) AS pay_cnt,
    MIN(created_at) AS first_pay_at
  FROM accounts_paymenthistory
  GROUP BY user_id
),
first_prod AS (
  SELECT
    p.user_id,
    p.productId AS first_product
  FROM accounts_paymenthistory p
  JOIN user_pay up
    ON p.user_id = up.user_id
   AND p.created_at = up.first_pay_at
)
SELECT
  COUNT(*) AS first_777_users,
  SUM(CASE WHEN up.pay_cnt >= 2 THEN 1 ELSE 0 END) AS repeat_users,
  ROUND(100.0 * SUM(CASE WHEN up.pay_cnt >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM first_prod fp
JOIN user_pay up ON up.user_id = fp.user_id
WHERE fp.first_product = 'heart.777'
;

-- 777 구매 유저의 제품 재구매 비율 
WITH user_summary AS (
  SELECT
    user_id,
    COUNT(*) AS pay_cnt,
    MIN(created_at) AS first_pay_date
  FROM accounts_paymenthistory
  GROUP BY user_id
),

first_777 AS (
  SELECT p.user_id, u.first_pay_date
  FROM accounts_paymenthistory p
  JOIN user_summary u
    ON p.user_id = u.user_id
   AND p.created_at = u.first_pay_date
  WHERE p.productId = 'heart.777'
),
repeat_users AS (
  SELECT user_id
  FROM user_summary
  WHERE pay_cnt >= 2
)
SELECT
  p.productId,
  COUNT(*) AS repurchase_count,
  ROUND(
    100.0 * COUNT(*) /
    (SELECT COUNT(*) FROM first_777 f JOIN repeat_users r ON f.user_id = r.user_id),
  2) AS ratio_pct
FROM accounts_paymenthistory p
JOIN first_777 f
  ON p.user_id = f.user_id
JOIN repeat_users r
  ON p.user_id = r.user_id
WHERE p.created_at > f.first_pay_date
GROUP BY p.productId
ORDER BY repurchase_count DESC;

WITH user_summary AS (
  SELECT
    user_id,
    COUNT(*) AS pay_cnt,
    MIN(created_at) AS first_pay_date
  FROM accounts_paymenthistory
  GROUP BY user_id
),

first_777 AS (
  SELECT p.user_id, u.first_pay_date
  FROM accounts_paymenthistory p
  JOIN user_summary u
    ON p.user_id = u.user_id
   AND p.created_at = u.first_pay_date
  WHERE p.productId = 'heart.777'
),

repeat_777_users AS (
  SELECT DISTINCT p.user_id
  FROM accounts_paymenthistory p
  JOIN first_777 f
    ON p.user_id = f.user_id
  WHERE p.created_at > f.first_pay_date
    AND p.productId = 'heart.777'
)
SELECT
  (SELECT COUNT(*) FROM first_777) AS first_777_users,
  (SELECT COUNT(*) FROM repeat_777_users) AS repeat_777_users,
  ROUND(
    100.0 *
    (SELECT COUNT(*) FROM repeat_777_users) /
    (SELECT COUNT(*) FROM first_777),
  2) AS repeat_777_ratio_pct
  ;


-- 1. 유저별 첫 결제 시점 구하기
WITH first_pay AS (
  SELECT
    user_id,
    MIN(created_at) AS first_pay_date
  FROM accounts_paymenthistory
  GROUP BY user_id
)
;

WITH user_summary AS (
  SELECT user_id, COUNT(*) AS pay_cnt
  FROM accounts_paymenthistory
  GROUP BY user_id
)
SELECT
  CASE WHEN pay_cnt = 1 THEN 'one_time(1회성 구매)'
       ELSE 'repeat(재구매)'
  END AS group_type,
  COUNT(*) AS users,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM user_summary), 2) AS ratio_pct
FROM user_summary
GROUP BY group_type
ORDER BY users DESC
;

WITH first_row AS (
  SELECT
    user_id,
    MIN(id) AS first_payment_id
  FROM accounts_paymenthistory
  GROUP BY user_id
),
first_pay AS (
  SELECT
    p.user_id,
    p.productId AS first_product
  FROM accounts_paymenthistory p
  JOIN first_row f
    ON p.user_id = f.user_id
   AND p.id = f.first_payment_id
),
user_pay_cnt AS (
  SELECT
    user_id,
    COUNT(*) AS pay_cnt
  FROM accounts_paymenthistory
  GROUP BY user_id
)
SELECT
  COUNT(*) AS first_777_users,
  SUM(CASE WHEN c.pay_cnt >= 2 THEN 1 ELSE 0 END) AS repeat_users,
  ROUND(100.0 * SUM(CASE WHEN c.pay_cnt >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM first_pay fp
JOIN user_pay_cnt c ON c.user_id = fp.user_id
WHERE fp.first_product = 'heart.777';

WITH user_summary AS (
  SELECT
    user_id,
    COUNT(*) AS pay_cnt,
    MIN(created_at) AS first_pay_at
  FROM accounts_paymenthistory
  GROUP BY user_id
),
first_pay_row AS (
  SELECT
    p.user_id,
    p.productId AS first_product,
    us.pay_cnt,
    us.first_pay_at
  FROM accounts_paymenthistory p
  JOIN user_summary us
    ON p.user_id = us.user_id
   AND p.created_at = us.first_pay_at
),
first_777_repeat_users AS (
  SELECT user_id, first_pay_at
  FROM first_pay_row
  WHERE first_product = 'heart.777'
    AND pay_cnt >= 2
),
repurchased_products AS (
  SELECT DISTINCT
    p.user_id,
    p.productId
  FROM accounts_paymenthistory p
  JOIN first_777_repeat_users f
    ON p.user_id = f.user_id
  WHERE p.created_at > f.first_pay_at
)
SELECT
  productId,
  COUNT(DISTINCT user_id) AS repurchase_users,
  ROUND(
    100.0 * COUNT(DISTINCT user_id) /
    (SELECT COUNT(*) FROM first_777_repeat_users),
  2) AS ratio_pct
FROM repurchased_products
GROUP BY productId
ORDER BY repurchase_users DESC;

WITH user_pay AS (
  SELECT user_id, COUNT(*) AS pay_cnt
  FROM accounts_paymenthistory
  GROUP BY user_id
),
repeat_users AS (
  SELECT user_id
  FROM user_pay
  WHERE pay_cnt >= 2
)SELECT
  u.gender,
  COUNT(*) AS repeat_users,
  ROUND(
    100.0 * COUNT(*) /
    (SELECT COUNT(*) FROM repeat_users),
  2) AS ratio_pct
FROM repeat_users r
JOIN accounts_user u
  ON r.user_id = u.id
GROUP BY u.gender
ORDER BY repeat_users DESC
;

WITH user_pay AS (
  SELECT user_id, COUNT(*) AS pay_cnt
  FROM accounts_paymenthistory
  GROUP BY user_id
),
repeat_users AS (
  SELECT user_id
  FROM user_pay
  WHERE pay_cnt >= 2
)
SELECT
  up.grade,
  COUNT(*) AS repeat_users,
  ROUND(
    100.0 * COUNT(*) /
    (SELECT COUNT(*) FROM repeat_users),
  2) AS ratio_pct
FROM repeat_users r
JOIN user_properties up
  ON r.user_id = up.user_id
GROUP BY up.grade
ORDER BY up.grade;

WITH user_pay AS (
  SELECT user_id, COUNT(*) AS pay_cnt
  FROM accounts_paymenthistory
  GROUP BY user_id
),
repeat_users AS (
  SELECT user_id
  FROM user_pay
  WHERE pay_cnt >= 2
)SELECT
  u.gender,
  up.grade,
  COUNT(*) AS repeat_users,
  ROUND(
    100.0 * COUNT(*) /
    (SELECT COUNT(*) FROM repeat_users),
  2) AS ratio_pct
FROM repeat_users r
JOIN accounts_user u
  ON r.user_id = u.id
JOIN user_properties up
  ON r.user_id = up.user_id
GROUP BY u.gender, up.grade
ORDER BY u.gender, up.grade
;
WITH active_users AS (
    SELECT COUNT(DISTINCT id) AS active_user_cnt
    FROM accounts_user
),
total_questions AS (
    SELECT COUNT(*) AS total_question_cnt
    FROM accounts_userquestionrecord
)
SELECT 
    q.total_question_cnt,
    u.active_user_cnt,
    (q.total_question_cnt * 1.0 / u.active_user_cnt) AS questions_per_user
FROM total_questions q
CROSS JOIN active_users u;


WITH monthly_questions AS (
    SELECT 
        DATE_FORMAT(created_at, '%Y-%m') AS ym,
        COUNT(*) AS question_cnt
    FROM accounts_userquestionrecord
    GROUP BY ym
),
monthly_users AS (
    SELECT 
        DATE_FORMAT(created_at, '%Y-%m') AS ym,
        COUNT(DISTINCT id) AS user_cnt
    FROM accounts_user
    GROUP BY ym
)
SELECT 
    q.ym,
    q.question_cnt,
    u.user_cnt,
    (q.question_cnt * 1.0 / u.user_cnt) AS questions_per_user
FROM monthly_questions q
LEFT JOIN monthly_users u
ON q.ym = u.ym
ORDER BY q.ym;