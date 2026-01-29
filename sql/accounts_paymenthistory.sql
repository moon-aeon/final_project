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
