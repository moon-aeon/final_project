USE docker_mysql;

SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN opened_times > 0 THEN 1 ELSE 0 END) AS opened,
  SUM(CASE WHEN has_read = 1 THEN 1 ELSE 0 END) AS r,
  SUM(CASE WHEN answer_status <> 'N' THEN 1 ELSE 0 END) AS answered,
  SUM(CASE WHEN answer_status = 'A' THEN 1 ELSE 0 END) AS public_answer
FROM accounts_userquestionrecord
WHERE YEAR(created_at) = 2023
    AND MONTH(created_at) = 5s
;

SELECT DISTINCT answer_status
FROM accounts_userquestionrecord
;

WITH ranked AS (
  SELECT chosen_user_id,
         COUNT(*) AS received_cnt,
         NTILE(10) OVER (ORDER BY COUNT(*) DESC) AS decile
  FROM accounts_userquestionrecord
  GROUP BY chosen_user_id
)
SELECT decile,
       SUM(received_cnt) AS total_received
FROM ranked
GROUP BY decile
ORDER BY decile;


WITH user_received AS (
    SELECT 
        chosen_user_id,
        COUNT(*) AS received_cnt
    FROM accounts_userquestionrecord
    GROUP BY chosen_user_id
), ranked AS (
    SELECT 
        chosen_user_id,
        received_cnt,
        ROW_NUMBER() OVER (ORDER BY received_cnt DESC) AS rn,
        COUNT(*) OVER () AS total_users,
        SUM(received_cnt) OVER () AS total_questions
    FROM user_received
)SELECT 
    ROUND(
        SUM(CASE 
                WHEN rn <= total_users * 0.1 
                THEN received_cnt 
            END) / MAX(total_questions) * 100
    ,2) AS top_10_percent_share,

    ROUND(
        SUM(CASE 
                WHEN rn > total_users * 0.5 
                THEN received_cnt 
            END) / MAX(total_questions) * 100
    ,2) AS bottom_50_percent_share
FROM ranked
;
WITH user_received AS (
    SELECT 
        chosen_user_id,
        COUNT(*) AS received_cnt
    FROM accounts_userquestionrecord
    GROUP BY chosen_user_id
),
ranked AS (
    SELECT 
        chosen_user_id,
        received_cnt,
        NTILE(10) OVER (ORDER BY received_cnt DESC) AS decile,
        SUM(received_cnt) OVER () AS total_questions
    FROM user_received
)
SELECT 
    decile,
    COUNT(*) AS user_cnt,
    SUM(received_cnt) AS question_cnt,
    ROUND(SUM(received_cnt) / MAX(total_questions) * 100, 2) AS share_percent
FROM ranked
GROUP BY decile
ORDER BY decile;
