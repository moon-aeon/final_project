-- 서비스에서 불쾌감 피로감을 느끼는 지점 찾을 수 있는 테이블! 이탈 분석ㄱㄱ
-- 기간 확인 (questionreport)
-- min_dt | max_dt | 
-- 2023-04-19 06:20:35	2024-05-05 14:56:25	51424	22171
SELECT 
  MIN(created_at) AS min_dt,
  MAX(created_at) AS max_dt,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS dau_users
FROM polls_questionreport;

-- 기간 확인 (set)
SELECT 
  MIN(created_at) AS min_dt,
  MAX(created_at) AS max_dt,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS users
FROM polls_questionset;


-- 기간 확인 (candidate)
SELECT 
  MIN(created_at) AS min_dt,
  MAX(created_at) AS max_dt,
  COUNT(*) AS total_rows,
  COUNT(DISTINCT user_id) AS users
FROM polls_usercandidate;

-- 기간이 조금씩 다르므로 공통 기간으로 맞춰 분석이 필요! (23년 4월 28일 ~ 24년 5월 5일)

