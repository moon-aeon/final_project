/* 1단계: 전체 유저 수, 성별 분포 및 기기 점유율 확인
분석 포인트: 
1. ban_status가 없는 유저를 정상 유저로 간주하여 집계합니다.
2. accounts_paymenthistory의 phone_type을 활용해 실제 매출 기여 기기를 파악합니다.
*/

-- 1. 전체 가입자 및 성별 분포 (accounts_user 기준)
SELECT 
    gender,
    COUNT(id) AS user_count,
    -- 전체 대비 비율
    ROUND(COUNT(id) * 100.0 / (SELECT COUNT(*) FROM accounts_user), 2) AS gender_ratio,
    -- 포인트 및 신고 횟수 평균
    ROUND(AVG(point), 0) AS avg_point_balance,
    ROUND(AVG(report_count), 2) AS avg_reported_times,
    -- ban_status에 어떤 값들이 들어있는지 샘플 확인 (필터링 원인 파악용)
    GROUP_CONCAT(DISTINCT ban_status) AS ban_status_samples
FROM 
    accounts_user
GROUP BY 
    gender;

/* 1-1단계: 성별 미지정 유저 상세 분석 (수정본)
분석 포인트: 
- 관리자 권한 여부와 'created_at'(가입일) 확인
- 보유 포인트가 비정상적으로 높은지 체크
*/
SELECT 
    id, 
    is_staff, 
    is_superuser, 
    point, 
    created_at, -- 명세서에 명시된 가입일 컬럼
    ban_status
FROM 
    accounts_user
WHERE 
    gender IS NULL OR gender = '';


-- 1-2. 여성이 남성보다 평균 포인트가 많았는데 그럼 구매도 여성이 높을까?
-- 성별 하트 충전율 및 매출 기여도 분석
SELECT 
    U.gender,
    COUNT(DISTINCT U.id) AS total_users,
    COUNT(DISTINCT P.user_id) AS paying_users,
    -- 결제 전환율 (전체 유저 중 실제 구매 경험자 비중)
    ROUND(COUNT(DISTINCT P.user_id) * 100.0 / COUNT(DISTINCT U.id), 2) AS conversion_rate,
    -- 총 구매 건수
    COUNT(P.id) AS total_purchase_count,
    -- 인당 평균 구매 횟수
    ROUND(COUNT(P.id) / COUNT(DISTINCT P.user_id), 1) AS avg_purchase_per_user
FROM 
    accounts_user U
LEFT JOIN 
    accounts_paymenthistory P ON U.id = P.user_id
WHERE 
    U.ban_status = 'N' -- 정상 유저 기준
GROUP BY 
    U.gender;



-- 2. 기기 점유율 분석 (결제 기록이 있는 유저 중심 - phone_type 활용)
-- I: iOS, A: Android
SELECT 
    CASE 
        WHEN phone_type = 'I' THEN 'iOS'
        WHEN phone_type = 'A' THEN 'Android'
        ELSE 'Unknown'
    END AS device_os,
    COUNT(DISTINCT user_id) AS paying_user_count,
    ROUND(COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(DISTINCT user_id) FROM accounts_paymenthistory), 2) AS os_ratio
FROM 
    accounts_paymenthistory
GROUP BY 
    phone_type;