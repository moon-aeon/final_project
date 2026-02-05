USE docker_mysql;

SELECT * 
FROM hackle_events
LIMIT 200
;

DESCRIBE hackle_events;

SELECT COUNT(*)
FROM hackle_events
;

SELECT MIN(event_datetime)
FROM hackle_events
;

SELECT COUNT(DISTINCT event_key)
FROM hackle_events
;

SELECT COUNT(DISTINCT session_id)
FROM hackle_events
;

SELECT COUNT(DISTINCT item_name)
FROM hackle_events
;

SELECT DISTINCT item_name
FROM hackle_events
;

SELECT COUNT(DISTINCT page_name)
FROM hackle_events
;

SELECT DISTINCT page_name
FROM hackle_events
;

SELECT MAX(friend_count)
FROM hackle_events
;

SELECT *
FROM hackle_events
WHERE friend_count = 1365
;

SELECT MIN(friend_count)
FROM hackle_events
WHERE friend_count != 0
;

SELECT COUNT(*)
FROM hackle_events
WHERE friend_count = 0
;