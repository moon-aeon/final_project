-- 서비스에서 불쾌감 피로감을 느끼는 지점 찾을 수 있는 테이블! 이탈 분석ㄱㄱ
-- 기간 확인 (questionreport)
-- min_dt | max_dt | 
-- 2023-04-19 06:20:35	2024-05-05 14:56:25	51424	22171
SELECT 
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT user_id) AS user_cnt
FROM polls_questionreport
WHERE created_at >= '2023-04-28'
  AND created_at < '2024-05-06';


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
SELECT 
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT user_id) AS user_cnt
FROM polls_questionset
WHERE created_at >= '2023-04-28'
  AND created_at < '2024-05-06';

SELECT 
  COUNT(*) AS row_cnt,
  COUNT(DISTINCT user_id) AS user_cnt
FROM polls_usercandidate
WHERE created_at >= '2023-04-28'
  AND created_at < '2024-05-06';


  COUNT(DISTINCT r.user_id) AS report_users,
  COUNT(DISTINCT c.user_id) AS candidate_users,
  COUNT(DISTINCT CASE WHEN c.user_id IS NOT NULL THEN r.user_id END) AS report_and_candidate_users
FROM (
  SELECT DISTINCT user_id
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
) r
LEFT JOIN (
  SELECT DISTINCT user_id
  FROM polls_usercandidate
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
) c
ON r.user_id = c.user_id;

-- usercandidate 에서 created_at 이 NULL 일 수 있는지? 이상값 체크 
-- NULL 없음 
SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_at
FROM polls_usercandidate;

SHOW COLUMNS FROM polls_usercandidate;

-- 다시 이전 쿼리 지우고 다시다시!!! 
-- 신고 유저수와 후보 유저수 그리고 둘다 겹치는 유저수 
-- 21826	19993	853

-- 이게 맞는거야... 나 도무지 모르겠는데? 살려주세요오
WITH report_users AS (
  SELECT DISTINCT user_id
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
),
candidate_users AS (
  SELECT DISTINCT user_id
  FROM polls_usercandidate
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
)
SELECT
  (SELECT COUNT(*) FROM report_users) AS report_users,
  (SELECT COUNT(*) FROM candidate_users) AS candidate_users,
  (SELECT COUNT(*) 
   FROM report_users r
   INNER JOIN candidate_users c
   ON r.user_id = c.user_id
  ) AS overlap_users;

-- 일단 각 데이터 테이블에서 샘플 뽑아 보기 
-- 833112 / 833113 / 833154 이런 형태
SELECT DISTINCT user_id
FROM polls_usercandidate
LIMIT 20;

-- 이제 신고 유저 뽑아보기 
-- 832340 / 833422 / 833626
SELECT DISTINCT user_id
FROM polls_questionreport
LIMIT 20;

-- 일단 두 샘플 모두 user_id 는 비슷해보임 

-- 여기서 겹치는 853명이 어떤 유저인지
-- 신고 참여도 높고, 후보 참여도 높은 비율임 
    -- 많이 노출되는 유저일수록 불쾌한 콘텐츠(질문)을 더 많이 접하게 되면서 신고율이 높아지는 것으로 보임 
WITH overlap AS (
  SELECT DISTINCT r.user_id
  FROM polls_questionreport r
  INNER JOIN polls_usercandidate c
    ON r.user_id = c.user_id
  WHERE r.created_at >= '2023-04-28'
    AND r.created_at < '2024-05-06'
    AND c.created_at >= '2023-04-28'
    AND c.created_at < '2024-05-06'
)
SELECT 
  o.user_id,
  (SELECT COUNT(*) FROM polls_questionreport r WHERE r.user_id=o.user_id) AS report_cnt,
  (SELECT COUNT(*) FROM polls_usercandidate c WHERE c.user_id=o.user_id) AS candidate_cnt
FROM overlap o
ORDER BY report_cnt DESC
LIMIT 50;

-- user_id 기준 통합 유저 마스터 
WITH report_summary AS (
  SELECT 
    user_id,
    COUNT(*) AS report_cnt,
    COUNT(DISTINCT question_id) AS report_question_cnt,
    MIN(created_at) AS first_report_dt,
    MAX(created_at) AS last_report_dt
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
  GROUP BY user_id
),
questionset_summary AS (
  SELECT
    user_id,
    COUNT(*) AS questionset_cnt,
    SUM(CASE WHEN status='F' THEN 1 ELSE 0 END) AS finished_cnt,
    SUM(CASE WHEN status='O' THEN 1 ELSE 0 END) AS opened_cnt,
    SUM(CASE WHEN status='C' THEN 1 ELSE 0 END) AS closed_cnt,
    MIN(created_at) AS first_questionset_dt,
    MAX(created_at) AS last_questionset_dt
  FROM polls_questionset
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
  GROUP BY user_id
),
candidate_summary AS (
  SELECT
    user_id,
    COUNT(*) AS candidate_cnt,
    COUNT(DISTINCT question_piece_id) AS candidate_question_cnt,
    MIN(created_at) AS first_candidate_dt,
    MAX(created_at) AS last_candidate_dt
  FROM polls_usercandidate
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
  GROUP BY user_id
),
all_users AS (
  SELECT user_id FROM report_summary
  UNION
  SELECT user_id FROM questionset_summary
  UNION
  SELECT user_id FROM candidate_summary
)
SELECT
  u.user_id,
  -- 신고 관련
  COALESCE(r.report_cnt, 0) AS report_cnt,
  COALESCE(r.report_question_cnt, 0) AS report_question_cnt,
  r.first_report_dt,
  r.last_report_dt,
  -- 질문세트 관련
  COALESCE(q.questionset_cnt, 0) AS questionset_cnt,
  COALESCE(q.finished_cnt, 0) AS finished_cnt,
  COALESCE(q.opened_cnt, 0) AS opened_cnt,
  COALESCE(q.closed_cnt, 0) AS closed_cnt,
  q.first_questionset_dt,
  q.last_questionset_dt,
  -- 후보 관련
  COALESCE(c.candidate_cnt, 0) AS candidate_cnt,
  COALESCE(c.candidate_question_cnt, 0) AS candidate_question_cnt,
  c.first_candidate_dt,
  c.last_candidate_dt
FROM all_users u
LEFT JOIN report_summary r ON u.user_id = r.user_id
LEFT JOIN questionset_summary q ON u.user_id = q.user_id
LEFT JOIN candidate_summary c ON u.user_id = c.user_id;

-- 원본 컬럼만 조인해서 유저별 1건만 샘플 보기
WITH report_last AS (
  SELECT r.*
  FROM polls_questionreport r
  INNER JOIN (
    SELECT user_id, MAX(created_at) AS max_dt
    FROM polls_questionreport
    WHERE created_at >= '2023-04-28'
      AND created_at < '2024-05-06'
    GROUP BY user_id
  ) t
  ON r.user_id = t.user_id AND r.created_at = t.max_dt
),
questionset_last AS (
  SELECT q.*
  FROM polls_questionset q
  INNER JOIN (
    SELECT user_id, MAX(created_at) AS max_dt
    FROM polls_questionset
    WHERE created_at >= '2023-04-28'
      AND created_at < '2024-05-06'
    GROUP BY user_id
  ) t
  ON q.user_id = t.user_id AND q.created_at = t.max_dt
),
candidate_last AS (
  SELECT c.*
  FROM polls_usercandidate c
  INNER JOIN (
    SELECT user_id, MAX(created_at) AS max_dt
    FROM polls_usercandidate
    WHERE created_at >= '2023-04-28'
      AND created_at < '2024-05-06'
    GROUP BY user_id
  ) t
  ON c.user_id = t.user_id AND c.created_at = t.max_dt
),
all_users AS (
  SELECT user_id FROM report_last
  UNION
  SELECT user_id FROM questionset_last
  UNION
  SELECT user_id FROM candidate_last
)
SELECT
  u.user_id,
  -- report 컬럼
  r.question_id AS report_question_id,
  r.reason AS report_reason,
  r.created_at AS report_created_at,
  -- questionset 컬럼
  q.question_piece_id_list,
  q.opening_time,
  q.status,
  q.created_at AS questionset_created_at,
  -- candidate 컬럼
  c.question_piece_id AS candidate_question_piece_id,
  c.created_at AS candidate_created_at
FROM all_users u
LEFT JOIN report_last r ON u.user_id = r.user_id
LEFT JOIN questionset_last q ON u.user_id = q.user_id
LEFT JOIN candidate_last c ON u.user_id = c.user_id;

-- 유저별 마지막 활동일  1
WITH all_events AS (
  SELECT user_id, created_at
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'

  UNION ALL

  SELECT user_id, created_at
  FROM polls_questionset
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'

  UNION ALL

  SELECT user_id, created_at
  FROM polls_usercandidate
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
),
user_last AS (
  SELECT
    user_id,
    MAX(created_at) AS last_dt,
    COUNT(*) AS total_events
  FROM all_events
  GROUP BY user_id
)
SELECT
  user_id,
  last_dt,
  total_events,
  CASE 
    WHEN last_dt < '2024-04-05' THEN 1
    ELSE 0
  END AS churn_30d
FROM user_last;

-- 신고 경험 있는 유저와 없는 유저 3
-- no_report	19140	| NULL
-- reported	853	 |  1.9977
WITH report_cnt AS (
  SELECT
    user_id,
    COUNT(*) AS report_count
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
  GROUP BY user_id
)
SELECT
  CASE 
    WHEN report_count IS NULL THEN 'no_report'
    ELSE 'reported'
  END AS report_group,
  COUNT(*) AS users,
  AVG(report_count) AS avg_report_cnt
FROM (
  SELECT u.user_id, r.report_count
  FROM (
    SELECT DISTINCT user_id
    FROM polls_usercandidate
    WHERE created_at >= '2023-04-28'
      AND created_at < '2024-05-06'
  ) u
  LEFT JOIN report_cnt r ON u.user_id = r.user_id
) t
GROUP BY report_group;


-- 신고 횟수 구간별 이탈률 비교 4
WITH all_events AS (
  SELECT user_id, created_at
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'

  UNION ALL
  SELECT user_id, created_at
  FROM polls_questionset
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'

  UNION ALL
  SELECT user_id, created_at
  FROM polls_usercandidate
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
),
user_last AS (
  SELECT
    user_id,
    MAX(created_at) AS last_dt
  FROM all_events
  GROUP BY user_id
),
report_cnt AS (
  SELECT
    user_id,
    COUNT(*) AS report_count
  FROM polls_questionreport
  WHERE created_at >= '2023-04-28'
    AND created_at < '2024-05-06'
  GROUP BY user_id
),
base AS (
  SELECT
    u.user_id,
    u.last_dt,
    COALESCE(r.report_count, 0) AS report_count,
    CASE WHEN u.last_dt < '2024-04-05' THEN 1 ELSE 0 END AS churn_30d
  FROM user_last u
  LEFT JOIN report_cnt r ON u.user_id = r.user_id
)
SELECT
  CASE
    WHEN report_count = 0 THEN '0'
    WHEN report_count = 1 THEN '1'
    WHEN report_count BETWEEN 2 AND 5 THEN '2-5'
    WHEN report_count BETWEEN 6 AND 10 THEN '6-10'
    ELSE '11+'
  END AS report_bucket,
  COUNT(*) AS users,
  SUM(churn_30d) AS churn_users,
  ROUND(SUM(churn_30d) / COUNT(*) * 100, 2) AS churn_rate_pct
FROM base
GROUP BY report_bucket
ORDER BY 
  CASE
    WHEN report_bucket = '0' THEN 1
    WHEN report_bucket = '1' THEN 2
    WHEN report_bucket = '2-5' THEN 3
    WHEN report_bucket = '6-10' THEN 4
    ELSE 5
  END;

---------------------------- 일단 조기 종료. 이건 나중에 다시 보자!!!! -----------------------------

-- 출석 횟수 및 최근 출석일 계산
-- 너무 많은데? 전체 행 수가 349637 
SELECT 
    user_id,
    -- JSON 배열일 경우 JSON_LENGTH 사용, 문자열일 경우 구분자 개수로 계산
    JSON_LENGTH(attendance_date_list) AS total_attendance_cnt,
    -- 리스트의 마지막 날짜(최근 출석일) 추출 (JSON 기준)
    REPLACE(JSON_EXTRACT(attendance_date_list, '$[last]'), '"', '') AS last_attendance_date,
    -- 가입 기간 대비 출석률 (생략 가능)
    DATEDIFF(NOW(), REPLACE(JSON_EXTRACT(attendance_date_list, '$[0]'), '"', '')) AS tenure_days
FROM accounts_attendance;

-- 유저가 얼마나 자주 오나 구간으로 나누기 
-- 출석 횟수 구간별 유저 수 분포 확인
SELECT 
    CASE 
        WHEN JSON_LENGTH(attendance_date_list) >= 30 THEN '30회 이상 (충성)'
        WHEN JSON_LENGTH(attendance_date_list) BETWEEN 10 AND 29 THEN '10-29회 (보통)'
        WHEN JSON_LENGTH(attendance_date_list) BETWEEN 2 AND 9 THEN '2-9회 (정착중)'
        ELSE '1회 (이탈 위험)'
    END AS user_segment,
    COUNT(*) AS user_count,
    ROUND(COUNT(*) / 349637 * 100, 2) AS percentage
FROM accounts_attendance
GROUP BY user_segment
ORDER BY user_count DESC;

-- 신고 유저와 비신고 유저 비교 (polls_questionreport 와 accounts_attendance)
-- 두 테이블의 공통 기간으로 통일 : 23년 5월 27일 ~ 24년 5월 5일 
SELECT 
    IF(r.user_id IS NULL, '일반 유저 (신고X)', '신고 유저 (신고O)') AS user_group,
    COUNT(a.user_id) AS total_user_count,
    ROUND(AVG(JSON_LENGTH(a.attendance_date_list)), 1) AS avg_attendance_cnt
FROM accounts_attendance a
LEFT JOIN (
    -- 질문 신고 기록을 지정된 교집합 기간으로 한정
    SELECT DISTINCT user_id 
    FROM polls_questionreport 
    WHERE created_at BETWEEN '2023-05-27' AND '2024-05-05'
) r ON a.user_id = r.user_id
-- 출석 리스트의 마지막 날짜가 분석 시작일 이후인 유저만 대상 (데이터 정합성)
WHERE STR_TO_DATE(REPLACE(JSON_EXTRACT(a.attendance_date_list, '$[last]'), '"', ''), '%Y-%m-%d') >= '2023-05-27'
GROUP BY user_group;

-- 신고 사유 별 영향력 분석 
SELECT 
    r.reason AS report_reason,
    COUNT(DISTINCT r.user_id) AS user_cnt,
    ROUND(AVG(JSON_LENGTH(a.attendance_date_list)), 1) AS avg_attendance_cnt
FROM polls_questionreport r
JOIN accounts_attendance a ON r.user_id = a.user_id
WHERE r.created_at BETWEEN '2023-05-27' AND '2024-05-05'
GROUP BY report_reason
ORDER BY avg_attendance_cnt ASC; 

-- 신고 이유에 따른 신고수 | 
SELECT 
    r.reason,
    COUNT(*) AS total_reports,
    -- 신고일이 마지막 출석일과 같은(즉, 신고하고 바로 나간) 유저 비율
    ROUND(SUM(CASE WHEN STR_TO_DATE(REPLACE(JSON_EXTRACT(a.attendance_date_list, '$[last]'), '"', ''), '%Y-%m-%d') = r.last_report_date THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_on_report_day_pct,
    -- 신고 이후에도 7일 이상 더 출석한 유저 비율
    ROUND(SUM(CASE WHEN DATEDIFF(STR_TO_DATE(REPLACE(JSON_EXTRACT(a.attendance_date_list, '$[last]'), '"', ''), '%Y-%m-%d'), r.last_report_date) >= 7 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS stayed_over_7days_pct
FROM (
    SELECT user_id, reason, MAX(created_at) AS last_report_date
    FROM polls_questionreport
    WHERE created_at BETWEEN '2023-05-27' AND '2024-05-05'
    GROUP BY user_id, reason
) r
JOIN accounts_attendance a ON r.user_id = a.user_id
GROUP BY r.reason
ORDER BY churn_on_report_day_pct DESC;

-- 5월 한달간 신고 사유별 발생 빈도 (주간)
SELECT 
    DATE_SUB(DATE(created_at), INTERVAL WEEKDAY(created_at) DAY) AS week_start,
    reason,
    COUNT(*) AS report_cnt
FROM polls_questionreport
WHERE created_at >= '2023-05-01'
  AND created_at < '2023-06-01'
GROUP BY week_start, reason
ORDER BY week_start ASC, report_cnt DESC;
