-- 20번 polls_questionset 테이블에서 question_piece_id_list 에 빈 값이 있는지 체크 
SELECT
  user_id,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN question_piece_id_list IS NULL THEN 1 ELSE 0 END) AS null_cnt,
  SUM(
    CASE
      WHEN question_piece_id_list IS NOT NULL
       AND JSON_LENGTH(question_piece_id_list) = 0
      THEN 1 ELSE 0
    END
  ) AS empty_list_cnt
FROM polls_questionset
GROUP BY user_id
HAVING null_cnt > 0 OR empty_list_cnt > 0
;

SELECT
  COUNT(*) AS suspicious_rows
FROM polls_questionset
WHERE
  question_piece_id_list IS NULL
  OR JSON_LENGTH(question_piece_id_list) = 0
  OR JSON_CONTAINS(question_piece_id_list, 'null');

-- status C,O,F 각각의 수 체크 
SELECT 
    status,
    COUNT(*) AS cnt
FROM polls_questionset
WHERE status IN ('C', 'O', 'F')
GROUP BY status
;