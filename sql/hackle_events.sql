-- 이벤트 로그

SELECT * FROM hackle_events;
SELECT COUNT(*) FROM hackle_events;

-- 집계 기간: 2023-07-18 00:00:00 ~ 2023-08-10 23:59:59
SELECT
    MIN(event_datetime),
    MAX(event_datetime)
FROM hackle_events
;

-- event_key: 44개
SELECT COUNT(DISTINCT event_key) FROM hackle_events;

-- event_id: 이벤트마다 생성되는 아이디, 11,441,319개
-- id: event_id와 마찬가지
SELECT COUNT(DISTINCT event_id) FROM hackle_events;

-- sesion_id: 고유값 253,616개 
-- event_key랑 같지도 않고 이벤트마다 생성되지도 않는 id, 도대체 무엇인가?
SELECT COUNT(DISTINCT session_id) FROM hackle_events;


SELECT COUNT(DISTINCT id) FROM hackle_events;

-- item_name: 777하트, 무료충전소, 1000 하트, 200 하트, 4000 하트
SELECT DISTINCT item_name FROM hackle_events;

-- page_name: 13개 페이지에서 이벤트 발생
SELECT DISTINCT page_name FROM hackle_events;
SELECT COUNT(DISTINCT page_name) FROM hackle_events;

SELECT friend_count FROM hackle_events;

-- 하트는 ping(질문)을 보낼 때 사용하는 것으로 보임

-- question_id(449,484개)는 event_key = 'skip_question'에만 있음
SELECT COUNT(DISTINCT question_id) FROM hackle_events;
SELECT 
    he.event_key,
    COUNT(he.question_id)
FROM hackle_events AS he
GROUP BY he.event_key
;