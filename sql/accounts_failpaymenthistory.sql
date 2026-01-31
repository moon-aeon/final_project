-- 상품 구매 실패 기록 테이블

SELECT * FROM accounts_failpaymenthistory

SELECT
    MIN(created_at),
    MAX(created_at)
FROM accounts_failpaymenthistory
;

-- 상품 수: 3개
SELECT
    COUNT(DISTINCT productId)
FROM accounts_failpaymenthistory

-- 상품별 구매 실패 횟수
    -- NULL 107개
SELECT
    productId,
    COUNT(created_at)
FROM accounts_failpaymenthistory
GROUP BY productId
;
-- 핸드폰 타입별 구매 실패 횟수
SELECT
    phone_type,
    COUNT(created_at) AS count
FROM accounts_failpaymenthistory
GROUP BY phone_type
;

SELECT
    phone_type,
    productId,
    COUNT(created_at) AS count
FROM accounts_failpaymenthistory
GROUP BY phone_type, productId
;

