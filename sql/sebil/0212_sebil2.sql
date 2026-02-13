-- 질문들이 5월에 어떻게 구성 되어 있는지를 확인
SELECT COUNT(DISTINCT question_text) 
FROM polls_question
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31';

SELECT DISTINCT question_text, created_at 
FROM polls_question
WHERE created_at >= '2023-05-01' AND created_at <= '2023-05-31'
ORDER BY created_at;

-------------------------------------------------------------------------------------------
-- accounts_userquestionrecord
-- event_receipts
-- user_properties
-- accounts_attendance

CREATE TABLE user_data AS
SELECT 
  COALESCE(aa.user_id, au.user_id, up.user_id, er.user_id) AS user_id,
  aa.attendance_date_list,
  au.chosen_user_id, au.opened_times, au.status, au.question_id,au.question_piece_id, 
        au.answer_status, au.answer_updated_at, au.report_count, au.has_read, au.created_at AS question_created_at,
  up.class, up.gender, up.grade, up.school_id,
  er.created_at AS event_created_at, er.event_id, er.plus_point
FROM accounts_attendance aa
INNER JOIN accounts_userquestionrecord au ON aa.user_id = au.user_id
INNER JOIN user_properties up ON aa.user_id = up.user_id
INNER JOIN event_receipts er ON aa.user_id = er.user_id;

SELECT * FROM user_data LIMIT 5;

DESCRIBE user_data;

-- user_id
-- attendance_date_list
-- chosen_user_id
-- opened_times
-- status
-- question_id
-- question_piece_id
-- answer_status
-- answer_updated_at
-- report_count
-- has_read
-- question_created_at
-- class
-- gender
-- grade
-- school_id
-- event_created_at
-- event_id
-- plus_point


-------------------------------------------------------------------------------------------------
--------------------------------accounts_attendance----------------------------------------------

DESCRIBE accounts_attendance;   -- user_id, attendance_date_list
SELECT * FROM accounts_attendance;

SELECT COUNT(DISTINCT user_id) FROM accounts_attendance;    -- 349637

-- 최대/최소 출석 값 -- max: 310 min:0
SELECT 
  user_id,
  JSON_LENGTH(attendance_date_list) AS attendance_count
FROM accounts_attendance
ORDER BY attendance_count DESC;     

-- 출석 안 한 유저 수 -- 20945
SELECT 
  COUNT(*)
FROM accounts_attendance
WHERE JSON_LENGTH(attendance_date_list) = 0; 

SELECT 
  ROUND(100.0 * 
    SUM(CASE WHEN JSON_LENGTH(attendance_date_list) > 0 THEN 1 ELSE 0 END) / COUNT(*), 
    2
  ) AS attendance_percentage,
  ROUND(100.0 * 
    SUM(CASE WHEN JSON_LENGTH(attendance_date_list) = 0 OR attendance_date_list IS NULL THEN 1 ELSE 0 END) / COUNT(*), 
    2
  ) AS non_attendance_percentage
FROM accounts_attendance;

-- 일별 출석 형황
SELECT 
  aa.user_id,
  DATE_FORMAT(STR_TO_DATE(jt.date_col, '%Y-%m-%d'), '%Y-%m-%d') AS month_year,
  COUNT(*) AS attendance_count
FROM accounts_attendance aa
CROSS JOIN JSON_TABLE(
  aa.attendance_date_list,
  '$[*]' COLUMNS (date_col VARCHAR(20) PATH '$')
) AS jt
WHERE aa.attendance_date_list IS NOT NULL
  AND STR_TO_DATE(jt.date_col, '%Y-%m-%d') IS NOT NULL
GROUP BY 
  aa.user_id, 
  DATE_FORMAT(STR_TO_DATE(jt.date_col, '%Y-%m-%d'), '%Y-%m-%d')
ORDER BY month_year;

SELECT 
  aa.user_id,
  DATE_FORMAT(STR_TO_DATE(jt.date_col, '%Y-%m-%d'), '%Y-%m') AS month_year,
  COUNT(*) AS attendance_count,
  COUNT(*) OVER (PARTITION BY aa.user_id) AS total_user_attendances
FROM accounts_attendance aa
CROSS JOIN JSON_TABLE(
  aa.attendance_date_list,
  '$[*]' COLUMNS (date_col VARCHAR(20) PATH '$')
) AS jt
WHERE aa.attendance_date_list IS NOT NULL
GROUP BY aa.user_id, DATE_FORMAT(STR_TO_DATE(jt.date_col, '%Y-%m-%d'), '%Y-%m')
ORDER BY aa.user_id, month_year;

-- 월별 출석 & 결석

SELECT 
  DATE_FORMAT(STR_TO_DATE(jt.date_col, '%Y-%m-%d'), '%Y-%m') AS month_year,
  COUNT(DISTINCT aa.user_id) AS total_attendees,
  (SELECT COUNT(*) 
   FROM accounts_attendance z 
   WHERE z.attendance_date_list IS NULL OR JSON_LENGTH(z.attendance_date_list) = 0) AS zero_attendance_users
FROM accounts_attendance aa
CROSS JOIN JSON_TABLE(
  aa.attendance_date_list, '$[*]' COLUMNS (date_col VARCHAR(20) PATH '$')
) AS jt
WHERE aa.attendance_date_list IS NOT NULL
GROUP BY month_year
ORDER BY month_year;

-------------------------------------------------------------------------------------------------------------------------
-----------------------------------------polls_questionreport------------------------------------------------------------
-- accounts_userquestionrecord
-- polls_questionpiece

--- tarihi de ayarla ayni zaman araligi
DESCRIBE polls_questionreport; -- user_id, reason, created_at, question_id
DESCRIBE accounts_userquestionrecord;   --user_id, question_id
DESCRIBE polls_questionpiece;   -- is_voted, created_at, question_id, is_skipped

-- JOIN 3 테이블
CREATE TABLE question_complete AS
SELECT 
  pq.user_id, pq.question_id, pq.reason, pq.created_at AS report_date,
  auqr.status, auqr.created_at AS record_date, auqr.chosen_user_id, auqr. question_piece_id,
        auqr.has_read, auqr.answer_status, auqr.answer_updated_at,
  pp.is_voted, pp.is_skipped, pp.created_at AS piece_date
FROM polls_questionreport pq
INNER JOIN accounts_userquestionrecord auqr 
  ON pq.user_id = auqr.user_id AND pq.question_id = auqr.question_id
INNER JOIN polls_questionpiece pp ON pq.question_id = pp.question_id;

SELECT * FROM question_complete LIMIT 3;

-- Shape & summary
SELECT 
  COUNT(*) AS total_records,                            -- 283007
  COUNT(DISTINCT user_id) AS unique_reporters,          -- 98
  COUNT(DISTINCT question_id) AS unique_questions       -- 101
FROM question_complete;

-- 
-- Power reporters
SELECT 
  user_id,
  COUNT(*) AS reports_made,
  COUNT(DISTINCT question_id) AS unique_questions_reported,
  GROUP_CONCAT(DISTINCT reason ORDER BY report_date SEPARATOR '; ') AS reasons
FROM question_complete
GROUP BY user_id
ORDER BY reports_made DESC
LIMIT 10;


--
SELECT 
  reason,
  COUNT(*) AS frequency,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM question_complete
GROUP BY reason
ORDER BY frequency DESC;


--
SELECT 
  is_voted,
  is_skipped,
  has_read,
  COUNT(*) AS interactions,
  ROUND(AVG(reason), 2) AS avg_reports,
  ROUND(100.0 * SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS closed_pct
FROM question_complete
GROUP BY is_voted, is_skipped, has_read
ORDER BY interactions DESC;

