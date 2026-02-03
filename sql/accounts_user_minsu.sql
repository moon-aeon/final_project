select * from accounts_user WHERE is_staff = 0;

select
    MIN(created_at),
    MAX(created_at)
from accounts_user

select COUNT(*) from accounts_user WHERE is_staff = 0;

-- 월별 유입 유저
-- - 5월에 급증하고 6월부터 다시 하락
-- - 이후 점차 감소하다 11월에 전월 대비 약 1.8배 상승
-- - 다시 점차 하락 2024-05에 두 자릿수 최저치 기록
select
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(*)
FROM accounts_user
GROUP BY YEAR(created_at), MONTH(created_at)