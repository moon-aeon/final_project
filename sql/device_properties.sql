-- device_properties 테이블 뜯어보기 
SELECT
  COUNT(DISTINCT device_id) AS devices,
  COUNT(DISTINCT device_model) AS models,
  COUNT(DISTINCT device_vendor) AS vendors
FROM device_properties
;

-- device_vendor 제조사 리스트 보기
SELECT
    DISTINCT(device_vendor)
FROM device_properties;

-- 제조사 비율 
SELECT
  device_vendor,
  COUNT(DISTINCT device_id) AS devices,
  ROUND(
    COUNT(DISTINCT device_id) * 100.0
    / SUM(COUNT(DISTINCT device_id)) OVER (), 2
  ) AS ratio_pct
FROM device_properties
GROUP BY device_vendor
ORDER BY devices DESC;

-- 롱테일 구조확인(모델별 누적 커버리지)
-- 각각 159
WITH model_cnt AS (
  SELECT
    device_model,
    COUNT(DISTINCT device_id) AS cnt
  FROM device_properties
  GROUP BY device_model
)
SELECT
  COUNT(*) AS model_cnt,
  SUM(cnt) AS device_cnt
FROM model_cnt
WHERE cnt = 1;

-- hackle_properties 와 조인해서 vendor 활성 세션 보기
SELECT
  d.device_vendor,
  COUNT(DISTINCT h.session_id) AS sessions,
  COUNT(DISTINCT h.device_id) AS devices
FROM hackle_properties h
JOIN device_properties d
  ON h.device_id = d.device_id
GROUP BY d.device_vendor
ORDER BY sessions DESC;