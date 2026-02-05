DESCRIBE accounts_user;
SELECT * FROM accounts_user ORDER BY id LIMIT 50;

SELECT COUNT(*) FROM accounts_user;       --677085

SELECT COUNT(DISTINCT(id)) FROM accounts_user; --677085
DESCRIBE accounts_userwithdraw;
SELECT * FROM accounts_userwithdraw ORDER BY id LIMIT 5;
DESCRIBE accounts_attendance;

SELECT * FROM accounts_attendance ORDER BY id;
DESCRIBE accounts_friendrequest;
DESCRIBE accounts_timelinereport;
DESCRIBE accounts_userquestionrecord;
DESCRIBE polls_question;
DESCRIBE polls_questionpiece;
DESCRIBE polls_questionset;
DESCRIBE polls_questionreport;
DESCRIBE polls_usercandidate;
DESCRIBE accounts_paymenthistory;
DESCRIBE accounts_failpaymenthistory;
DESCRIBE accounts_pointhistory;
DESCRIBE event_receipts;
DESCRIBE events;
DESCRIBE accounts_group;
DESCRIBE accounts_school;
DESCRIBE accounts_nearbyschool;
DESCRIBE accounts_user_contacts;

---------------------------------------------------------------------------

-- 월별 이탈률 추세
SELECT
    DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd,
    COUNT(*) AS churn_cnt
FROM accounts_userwithdraw
GROUP BY ymd
ORDER BY ymd;

-- 2023-04-17	4
-- 2023-04-19	56    ???
-- 2023-04-20	100

-- 2023-04-28	150
-- 2023-04-29	496   ???

-- 2023-05-05	719
-- 2023-05-06	1683    ???

-- 2023-05-26	1319
-- 2023-05-27	677     ???
-- 2023-05-28	11      ???

-- 2023-06-01	2
-- 2023-06-02	205   ???
-- 2023-06-03	759   ???

-------------------------------------------------------------------------------

SELECT * FROM accounts_user LIMIT 5;

--이탈 유저의 특징
SELECT 
    DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd,
    COUNT(*) AS user_count,
    SUM(CASE 
        WHEN friend_id_list IS NULL OR friend_id_list = '[]' THEN 0
        ELSE JSON_LENGTH(friend_id_list)
    END) AS sum_friend_count,
    SUM(CASE 
        WHEN block_user_id_list IS NULL OR block_user_id_list = '[]' THEN 0
        ELSE JSON_LENGTH(block_user_id_list)
    END) AS sum_block_count,
    SUM(report_count) AS total_reports
FROM accounts_user
WHERE created_at >= '2023-04-01' AND created_at < '2023-07-01'
    AND ban_status = 'W'
GROUP BY ymd
ORDER BY ymd;

--이탈하지 않는 유저의 특징
SELECT 
    DATE_FORMAT(created_at, '%Y-%m-%d') AS ymd,
    COUNT(*) AS user_count,
    SUM(CASE 
        WHEN friend_id_list IS NULL OR friend_id_list = '[]' THEN 0
        ELSE JSON_LENGTH(friend_id_list)
    END) AS sum_friend_count,
    SUM(CASE 
        WHEN block_user_id_list IS NULL OR block_user_id_list = '[]' THEN 0
        ELSE JSON_LENGTH(block_user_id_list)
    END) AS sum_block_count,
    SUM(report_count) AS total_reports
FROM accounts_user
WHERE created_at >= '2023-04-01' AND created_at < '2023-07-01'
    AND ban_status != 'W'
GROUP BY ymd
ORDER BY ymd;

------------------------------------------------------------------
SELECT COUNT(*) 
FROM accounts_userwithdraw
WHERE created_at >= '2023-04-01' AND created_at < '2023-07-01';     --57105

SELECT COUNT(*) 
FROM accounts_user
WHERE created_at >= '2023-04-01' AND created_at < '2023-07-01' AND ban_status = 'W';    --7314

SELECT COUNT(*) 
FROM accounts_user
WHERE id IS NOT NULL;

--------------------------
-- 월별 이탈 이유 추세
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    reason,
    COUNT(*) AS withdrawal_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY DATE_FORMAT(created_at, '%Y-%m')), 2) AS percentage_of_month
FROM accounts_userwithdraw
WHERE created_at >= '2023-04-01' AND created_at < '2023-07-01'
GROUP BY month, reason
ORDER BY month, withdrawal_count DESC;

----------------------------------------------------
----------------------------------------------------
