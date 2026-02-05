-- 가까운 학교를 기록해두기 위한 관계형 테이블

select * from accounts_nearbyschool;
select count(*) from accounts_nearbyschool;

-- 학교별 가까운 학교 수: 모든 학교가 10개
select 
    school_id,
    COUNT(nearby_school_id)
FROM accounts_nearbyschool
GROUP BY school_id;