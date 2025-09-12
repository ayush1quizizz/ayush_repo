




WITH weekly_game_and_students_per_game AS (
SELECT DISTINCT
  DATE_TRUNC(DATE(g2.created_at), WEEK) as wk,
  EXTRACT(YEAR FROM DATE_TRUNC(DATE(g2.created_at), WEEK) ) as yr,
    --g2.game_id,
    -- COUNT(DISTINCT ga2.session_id) AS students_count
    ga2.user_id
  FROM `quizizz-org.clean.game` g2
  LEFT JOIN `quizizz-org.clean.game_attempt` ga2 ON g2.game_id = ga2.game_id
  WHERE g2.is_classroom_game 
    AND g2.host_occupation = 'teacher'
    AND g2.host_country = 'US'
    AND DATE(ga2.game_created_at) >= '2024-01-01' 
    AND DATE(g2.created_at) >= '2024-01-01'
  --GROUP BY 1,2
)
-- ,visit as (
-- SELECT 
-- from track.all
-- WHERE event_group = 'pageview3'
-- AND occupation
-- )

SELECT a.yr, 
       a.wk,
       COUNT(DISTINCT a.user_id) AS was,
       COUNT(DISTINCT b.user_id) AS reten,
FROM weekly_game_and_students_per_game a 
LEFT JOIN weekly_game_and_students_per_game b 
ON a.user_id = b.user_id
AND TIMESTAMP_DIFF(b.wk,a.wk,week) = 1
GROUP BY 1,2
-- weekly_student_metrics AS (
-- SELECT 
--   DATE_TRUNC(DATE(ga.game_created_at), WEEK) as week,
--   COUNT(DISTINCT ga.user_id) AS weekly_active_students,
--   COUNT(DISTINCT ga.session_id) AS total_students
-- -- FROM `quizizz-org.clean.game_attempt` ga
-- -- INNER JOIN `quizizz-org.clean.game` g ON ga.game_id = g.game_id
-- -- WHERE DATE(ga.game_created_at) >= '2024-01-01'  
-- --   AND g.is_classroom_game 
-- --   AND g.host_occupation = 'teacher'
-- --   AND g.host_country = 'US'
-- --   AND DATE(g.created_at) >= '2024-01-01'
-- -- GROUP BY 1
-- -- ),

-- weekly_games AS (
-- SELECT 
--   wgspg.week,
--   COALESCE(wsm.weekly_active_students, 0) AS weekly_active_students,
--   COALESCE(wsm.total_students, 0) AS total_students,
--   wgspg.avg_completion_rate,
--   wgspg.responses_per_student,
--   wgspg.total_games_played,
--   wgspg.students_per_game
-- FROM weekly_game_and_students_per_game wgspg
-- LEFT JOIN weekly_student_metrics wsm ON wgspg.week = wsm.week
-- ),

-- weekly_registrations AS (
-- SELECT 
--   DATE_TRUNC(DATE(created_at), WEEK) as week,
--   COUNT(DISTINCT user_id) AS new_registrations
-- FROM `quizizz-org.clean.user`
-- WHERE DATE(created_at) >= '2024-01-01'
--   AND country = 'US'
--   AND occupation = 'student'
-- GROUP BY 1
-- ),

-- go_to_shop AS (
-- SELECT 
--   DATE(DATE_TRUNC(created_at,week)) as wk,
--   COUNT(DISTINCT user_id) AS shop_users
-- FROM `quizizz-org.track.ce_go_to_shop`
-- WHERE DATE(created_at) >= '2023-01-01'
-- AND country = 'US'  
-- AND occupation = 'student'
-- GROUP BY 1
-- ),

-- final_spend_user_level AS (
-- SELECT
-- DATE(DATE_TRUNC(item.unlocked_at,week)) AS unlocked_wk,
-- a.user_id,
-- COUNT(DISTINCT item.item_id) AS total_transactions,
-- SUM(SAFE_CAST(item.price AS INT64)) AS spent_amt
-- FROM `quizizz-org.clean.user_avatar` a
-- LEFT JOIN `quizizz-org.clean.user` u 
-- ON a.user_id = u.user_id,
-- UNNEST((unlocked_items)) AS item
-- WHERE DATE(a.created_at)>= '2023-01-01'  
-- AND item.item_id IS NOT NULL
-- AND item.price IS NOT NULL
-- AND country = 'US'
-- AND occupation = 'student'
-- GROUP BY 1, 2
-- ),

-- final_spend AS (
-- SELECT
-- unlocked_wk,
-- COUNT(DISTINCT user_id) AS spend_users,
-- SUM(total_transactions) AS total_transactions,
-- SUM(spent_amt) AS spent_amt
-- FROM final_spend_user_level
-- GROUP BY 1
-- ),

-- final_earn AS (
-- SELECT
-- DATE_TRUNC(DATE(TIMESTAMP_MILLIS(CAST(CAST(JSON_VALUE(a.state, '$.createdAt') AS FLOAT64) AS INT))), WEEK) AS earned_wk,
-- COUNT(DISTINCT JSON_VALUE(a.state, '$.userId')) AS earned_users,
-- SUM(COALESCE(CAST(JSON_VALUE(a.state, '$.reward.value.weeklyReward') AS numeric),0) +
--  COALESCE(CAST(JSON_VALUE(a.state, '$.reward.value.dailyReward') AS numeric),0) +
--  COALESCE(CAST(JSON_VALUE(a.state, '$.reward.value.completion') AS numeric),0) +
--  COALESCE(CAST(JSON_VALUE(a.state, '$.reward.value.accuracy') AS numeric),0) +
--  COALESCE(CAST(JSON_VALUE(a.state, '$.reward.value.powerups') AS numeric),0) +
--  COALESCE(CAST(JSON_VALUE(a.state, '$.reward.value.questions') AS numeric),0)) AS total_reward
-- FROM  `quizizz-org.analytics_v4.playerRewards` a
-- LEFT JOIN `quizizz-org.clean.user` u 
-- ON JSON_VALUE(a.state, '$.userId') = u.user_id
-- WHERE DATE(a._PARTITIONTIME) >= '2023-01-01'  
-- AND JSON_VALUE(a.state, '$.triggerEvent') in ('player_game_ended', 'user_login')
-- AND country = 'US'
-- AND occupation = 'student'
-- GROUP BY 1
-- )

