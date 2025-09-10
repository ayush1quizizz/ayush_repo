WITH new_ff as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-08' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id in (
    --'game_setting_v3'
--,'session-setup-experiment'
--,'mode-selection'
'delivery-global-control'
)
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)

SELECT DATE(A.dt) AS Date, 
       variation_id, 
       COUNT(DISTINCT A.user_id) AS users, 
       COUNT(DISTINCT B.host_id) AS hosts, 
       COUNT(DISTINCT B.game_id) AS games,
       COUNT(DISTINCT CASE WHEN B.is_classroom_game THEN B.host_id END) AS mg_hosts,
       COUNT(DISTINCT CASE WHEN B.is_classroom_game THEN B.game_id END) AS mg_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Live' THEN B.game_id END) AS live_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Homework' THEN B.game_id END) AS hw_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Live' AND game_type LIKE '%tp%' THEN B.game_id END) AS live_tp_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Live' AND game_type NOT LIKE '%tp%' THEN B.game_id END) AS live_sp_games,

FROM new_ff A
LEFT JOIN clean.game B
ON A.user_id = B.host_id
--AND is_classroom_game
AND DATE(B.created_at) >= '2025-09-08'
AND DATE(A.dt) = DATE(B.created_at)
GROUP BY 1,2
ORDER BY 1,2