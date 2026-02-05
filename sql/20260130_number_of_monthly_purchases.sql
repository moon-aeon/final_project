-- hackle_events 테이블 집계기간을 기준으로 데이터 탐색
SELECT
    COUNT(*)
FROM accounts_paymenthistory
WHERE created_at < '2023-07-01 00:00:00'
;

SELECT
    COUNT(*)
FROM accounts_paymenthistory
WHERE created_at >= '2023-07-01 00:00:00'
;

SELECT
    COUNT(*)
FROM accounts_paymenthistory
;

SELECT 
    89897 / COUNT(*)
FROM accounts_paymenthistory

SELECT 
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(created_at) AS purchase_count
FROM accounts_paymenthistory
GROUP BY 1, 2
;


WITH may_payment AS (
    SELECT 
        *
    FROM accounts_paymenthistory
    WHERE created_at < '2023-06-01 00:00:00'
)
SELECT
    COUNT(*)
FROM may_payment
WHERE created_at >= '2023-05-14 00:00:00'


-- 월별 탈퇴 유저
    -- 5월달부터 급증, 5월말 급감, 6월 급증, 이후 점차 감소
    -- 5월 13일 탈퇴 유저 수가 가장 높음

-- 월별 구매 건수
    -- 5월 구매 건수가 전체 대비 90% 이상 차지
    -- 1.5 업데이트(2023-05-13, 하트 충전소 출시) 직후 구매 건수 몰렸지만 6월부터 급락
    -- 유료 서비스로 전환 실패

-- 투표 및 친구 요청
    -- 6월 이후부터 투표 건수 하락
    -- 4 - 6월에 친구 요청 건수 집중
    -- -> 이미 관계 형성이 끝나 새로운 친구를 만들지 않는 유저들로 보인다. 

-- -> 1.5 업데이트 전후 비교 필요
-- -> ‘학교에서 친구들을 직접 만나니까 어플은 하교 후에 주로 사용하지 않을까?’ -> 사용 시간대 확인
-- -> 이탈이 집중되어 있는 5월달 탈퇴 요인을 파악해야 한다.

-- 왜 이탈했을까??
    -- 유저가 서비스 이용을 유지하기 좋은 환경이 아니다.
    -- 유료화가 되면서 이탈
    -- 부정적인 경험으로 인한 탈퇴
    -- 기타(4만 건) 사유 파악할 필요 있음