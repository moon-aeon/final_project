-- 친구 요청 테이블

SELECT
    MIN(created_at),
    MAX(created_at)
FROM accounts_friendrequest
;

SELECT
    MIN(updated_at),
    MAX(updated_at)
FROM accounts_friendrequest
;

SELECT * FROM accounts_friendrequest

-- 상태: P(대기)는 created_at과 updated_at이 같음

select status, count(receive_user_id) from accounts_friendrequest GROUP BY status