---super format (games which are being played) (engagement.vs_super_format_bundle_review)


WITH srp_users AS
(
SELECT DISTINCT
DATE(a.created_at) AS created_dt,
a.user_id,
CASE WHEN u.country='US' THEN 'US' ELSE 'ROW' END AS country,
email,
FROM `quizizz-org.track.search_results_pageview` a
INNER JOIN `quizizz-org.clean.user` u
ON a.user_id=u.user_id
WHERE   DATE(a.created_at) >=  CURRENT_DATE - 7 
--WHERE DATE(a.created_at)>='2025-02-21'
AND u.occupation='teacher'
AND u.country='US'
AND email NOT LIKE '%quizizz.com'
AND email NOT LIKE '%wayground.com'
)


,tab_changed_to_lesson AS (
SELECT DISTINCT
DATE(created_at) AS created_dt,
user_id
FROM `quizizz-org.track.searchEvent_tabChanged` 
WHERE   DATE(created_at) >=  CURRENT_DATE - 7 
AND current_tab='presentation'
)


, super_format_shown_on_srp AS 
(
  SELECT DISTINCT
    DATE(created_at) AS created_dt,
    user_id,
    superformatname AS super_format_name,
    bundleid AS super_format_id
  FROM `quizizz-org.track.superformat_searchcard_shown` 
  WHERE   DATE(created_at) >=  CURRENT_DATE - 7 

)


, bundle_previewed AS (
    SELECT DISTINCT
      DATE(created_at) AS created_dt,
      user_id,
      superformatid AS super_format_id
    FROM `quizizz-org.track.super_format_preview_shown` 
    WHERE   DATE(created_at) >=  CURRENT_DATE - 7 
    )

, super_format_adp_pageview AS
    (
    SELECT DISTINCT
      DATE(created_at) AS created_dt,
      user_id,
      REGEXP_EXTRACT(url, r'/([^/]+)$') AS super_format_id
    FROM `quizizz-org.track.admin_lesson_collection_settings_lessonCollectionId_pageview`
    WHERE   DATE(created_at) >=  CURRENT_DATE - 7 

    )

,super_format_adp_gamesetting AS (
SELECT DISTINCT
DATE(created_at) AS created_dt,
user_id,
REGEXP_EXTRACT(url, r'/([^/]+)/modify$') AS super_format_id
FROM `quizizz-org.track.admin_lesson_collection_settings_lessonCollectionId_modify_pageview` 
WHERE   DATE(created_at) >=  CURRENT_DATE - 7 
--DATE(created_at)>='2025-02-21'
)



, super_format_to_quiz_mapping AS (
SELECT
bundle_id,
is_verified,
reviewed,
name,
overall_rating,
id AS format_id,
format_type
FROM (
SELECT
bundle_id,
is_verified,
reviewed,
name,
overall_rating,
presentation AS presentation_id,
video AS video_id,
review_quiz AS review_quiz_id,
practice_quiz AS practice_quiz_id,
passage AS passage_id,
flashcard AS flashcard_id
FROM `quizizz-org.search.super-format-bundles`
) AS source_data
UNPIVOT (
id FOR format_type IN (
presentation_id AS 'presentation',
video_id AS 'video',
review_quiz_id AS 'review_quiz',
practice_quiz_id AS 'practice_quiz',
passage_id AS 'passage',
flashcard_id AS 'flashcard'
)
) AS unpivoted_data
)

,super_format_adp_gamesetting2 AS
(SELECT a.*, b.*
FROM super_format_adp_gamesetting a
LEFT JOIN super_format_to_quiz_mapping b
ON a.super_format_id= b.bundle_id
)



,super_format_shown_on_srp2 AS
  (SELECT a.*, b.*
  FROM super_format_shown_on_srp a
  LEFT JOIN super_format_to_quiz_mapping b
  ON a.super_format_id= b.bundle_id
  )

, super_format_adp_pageview2 AS
(SELECT a.*, b.*, email,u.country
  FROM super_format_adp_pageview a
  LEFT JOIN super_format_to_quiz_mapping b
  ON a.super_format_id= b.bundle_id
  INNER JOIN `quizizz-org.clean.user` u
  ON a.user_id=u.user_id
  AND u.occupation='teacher'
  AND u.country='US'
  AND email NOT LIKE '%quizizz.com'
  AND email NOT LIKE '%wayground.com'
  )



,super_format_lesson_started AS (
SELECT DISTINCT
DATE(created_at) AS created_dt,
user_id,
REGEXP_EXTRACT(url, r'/([^/]+)$') AS quiz_id
FROM `quizizz-org.track.admin_dashboards_lesson_id_pageview`
WHERE   DATE(created_at) >=  CURRENT_DATE - 7 
-- DATE(created_at)>='2025-02-21'
)


, game AS (
SELECT game_id, quiz_id, host_id, COUNT(DISTINCT game_id) OVER (PARTITION BY host_id) AS host_games, DATE(created_at) AS created_dt,created_at,
players, responses
FROM `quizizz-org.clean.game`
WHERE 
      DATE(created_at) >=  CURRENT_DATE - 7 
--DATE(created_at)>='2025-02-21'
AND host_country='US'
AND host_occupation='teacher'
-- AND players>1 AND responses>0
)


SELECT DISTINCT
d.created_dt,
d.country,
d.super_format_id AS super_format_id_shown,
d.is_verified,
d.reviewed,
d.name,
d.overall_rating,
d.user_id AS sf_adp_user_id,
email,
CASE WHEN players>1 AND responses>0 THEN g.host_id END AS game_user_id,
COUNT(DISTINCT d.user_id) AS sf_adp_users,
COUNT(DISTINCT e.user_id) AS sf_gs_users,
COUNT(DISTINCT g.host_id) AS sf_game_hosts,
COUNT(DISTINCT CASE WHEN players>1 AND responses>0 THEN g.host_id END) AS sf_valid_game_hosts,
-- FROM srp_users a
-- INNER JOIN tab_changed_to_lesson b
-- ON a.created_dt=b.created_dt AND a.user_id=b.user_id
-- -- LEFT JOIN super_format_shown_on_srp2 sfs_srp
-- -- ON b.created_dt=sfs_srp.created_dt AND b.user_id=sfs_srp.user_id
-- INNER JOIN bundle_previewed c
-- ON b.created_dt=c.created_dt AND b.user_id=c.user_id
FROM super_format_adp_pageview2 d
-- ON c.created_dt=d.created_dt AND c.user_id=d.user_id AND c.super_format_id= d.super_format_id
LEFT JOIN super_format_adp_gamesetting2 e
ON d.created_dt=e.created_dt AND d.user_id=e.user_id AND d.super_format_id= e.super_format_id
LEFT JOIN game g
ON e.created_dt=g.created_dt AND e.user_id=g.host_id AND e.format_id=g.quiz_id
GROUP BY 1,2,3,4,5,6,7,8,9,10