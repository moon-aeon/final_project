--구매 기록 테이블

--hackle_events 집계 기간: 2023-07-18 ~ 08-10
SELECT * FROM accounts_paymenthistory;

SELECT
    MIN(created_at),
    MAX(created_at)
FROM 
accounts_paymenthistory


