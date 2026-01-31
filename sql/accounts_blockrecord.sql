-- 차단 기록 테이블
    -- 이유
    -- 차단 일자
    -- 차단 유저 아이디
    -- 유저 아이디
select *
from accounts_blockrecord;

SELECT
    MIN(created_at),
    MAX(created_at)
FROM accounts_blockrecord
;


SELECT DISTINCT
    user_id,
    block_user_id
FROM accounts_blockrecord;

-- 차단 이유: 7가지
-- 그냥, 친구 사이가 어색해짐, 나랑 관련 없는 질문을 자꾸 보냄, 기타, 모르는 사람임, 너무 많은 양의 질문을 보냄, 사칭 계정
select 
    count(distinct reason)
from accounts_blockrecord
;
select 
    distinct reason
from accounts_blockrecord
;

-- 차단 이유별 차단 수
select 
    reason,
    count(block_user_id)
from accounts_blockrecord
group by reason
;

-- 최대 차단 수: 171개
SELECT
    MAX(block_count)
FROM (
    SELECT
        user_id,
        (count(block_user_id)) as block_count
    FROM accounts_blockrecord
    GROUP BY user_id
) as block_count
;

-- 평균 차단 수: 1.6개
SELECT
    AVG(block_count)
FROM (
    SELECT
        user_id,
        (count(block_user_id)) as block_count
    FROM accounts_blockrecord
    GROUP BY user_id
) as block_count
;

-- 차단 수 표준편차: 8.2
SELECT
    VAR_SAMP(block_count)
FROM (
    SELECT
        user_id,
        (count(block_user_id)) as block_count
    FROM accounts_blockrecord
    GROUP BY user_id
) as block_count
;

SELECT
    count(distinct user_id)
FROM accounts_blockrecord
;

SELECT 
    COUNT(*) AS duplicate_pair_count
FROM (
    SELECT 
        user_id,
        block_user_id
    FROM accounts_blockrecord
    GROUP BY user_id, block_user_id
    HAVING COUNT(*) > 1
) AS t;

-- 월별 차단 횟수
SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(created_at) as count
FROM accounts_blockrecord
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY count DESC
LIMIT 5
;