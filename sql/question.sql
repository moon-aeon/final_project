-- polls_questionreport (질문 신고 기록 테이블)
-- polls_questionpiece (질문 조각 테이블)
-- polls_usercandidate (질문 조각에 등장하는 유저들 테이블): 한 질문에 선택지 4명. 친구가 4명 이상 있어야 ping이 가능
-- polls_questionset (질문 세트 테이블)

select * from polls_questionpiece;
select * from polls_questionreport;
select * from polls_usercandidate;
select * from polls_questionset;

select COUNT(*) from polls_questionpiece; -- 1,265,476 행
select COUNT(*) from polls_usercandidate; -- 4,769,609 행
select COUNT(*) from polls_questionset; -- 158,384 행
select COUNT(DISTINCT user_id) from polls_questionset; -- 4,972 명

select
    MIN(created_at),
    MAX(created_at)
from polls_questionset

select COUNT(*) from accounts_user;
select 4972/677085;

select
COUNT(*)
from accounts_userquestionrecord;
select * from accounts_userquestionrecord;
select
    MIN(created_at),
    MAX(created_at)
from accounts_userquestionrecord

select
    YEAR(answer_updated_at) AS year,
    MONTH(answer_updated_at) AS month,
    COUNT(chosen_user_id) AS count
from accounts_userquestionrecord
group by year, month
;

select 200264100/677085

