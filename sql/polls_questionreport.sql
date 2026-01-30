-- 19번 polls_questionreport 테이블에서 reason 질문의 비율 보기(고유 / 고유 아닌 값)
SELECT
  reason,
  COUNT(question_id) AS reported_question_cnt,
  ROUND(
    COUNT(question_id) * 100.0
    / SUM(COUNT(question_id)) OVER (),
    2
  ) AS ratio_pct
FROM polls_questionreport
GROUP BY reason
ORDER BY reported_question_cnt DESC;