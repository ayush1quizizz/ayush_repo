WITH base AS (
  SELECT DISTINCT
    ff.user_id,
    DATE(ff.experiment_date) AS dt,
    ff.variation_id
  FROM transformed.user_feature_flag_map_most_frequent_in_a_day ff
  INNER JOIN clean.user u
    ON ff.user_id = u.user_id
  WHERE DATE(ff.experiment_date) >= '2025-09-09'
    AND DATE(ff.experiment_date) < CURRENT_DATE()
    AND ff.experiment_id = 'game_setting_v3'
    AND u.email NOT LIKE '%quizizz.com'
    AND u.email NOT LIKE '%wayground.com'
    AND u.country = 'US'
    AND u.occupation = 'teacher'
)
, game_settings_land AS (
  SELECT DISTINCT
    b.dt,
    b.user_id,
    b.variation_id,
    p.created_at AS gs_created_at,
    g.created_at AS game_created_at,
    g.game_id
  FROM base b
  INNER JOIN track.game_settings_pageview p
    ON b.user_id = p.user_id
   AND DATE(b.dt) = DATE(p.created_at)
   AND DATE(p.created_at) >= '2025-09-09'
   AND DATE(p.created_at) < CURRENT_DATE()
  INNER JOIN clean.game g
    ON p.user_id = g.host_id
   AND DATE(p.created_at) = DATE(g.created_at)
   AND TIMESTAMP_DIFF(g.created_at, p.created_at, SECOND) BETWEEN 0 AND 600
   AND DATE(g.created_at) >= '2025-09-09'
   AND DATE(g.created_at) < CURRENT_DATE()
   AND g.is_classroom_game
)
, times AS (
  SELECT
    variation_id,
    TIMESTAMP_DIFF(game_created_at, gs_created_at, SECOND) AS time_taken_seconds,
    PERCENT_RANK() OVER (
      PARTITION BY variation_id
      ORDER BY TIMESTAMP_DIFF(game_created_at, gs_created_at, SECOND)
    ) AS pr
  FROM game_settings_land
)
SELECT
  variation_id,
  MIN(time_taken_seconds) AS p90_time_taken_seconds
FROM times
WHERE pr >= 0.9
GROUP BY variation_id
ORDER BY variation_id;
