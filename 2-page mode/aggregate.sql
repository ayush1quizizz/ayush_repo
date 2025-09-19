WITH new_ff as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-15' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'mode-selection'
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)

SELECT
--A.dt,
variation_id,
COUNT(DISTINCT user_id) as users,
COUNT(DISTINCT host_id) as hosts,
COUNT(DISTINCT CASE WHEN is_classroom_game THEN host_id END) AS mg_hosts,
COUNT(DISTINCT game_id) as games,
COUNT(DISTINCT CASE WHEN is_classroom_game THEN game_id END) AS mg_games,
count(distinct case when is_classroom_game AND is_accommodations_used = true then game_id end) as accom_games_2,
count(distinct case when is_classroom_game AND is_assigned = true then game_id end) as assigned_games,
count(distinct case when is_classroom_game and questions >= 10 and game_type_group = 'Live' then game_id end) as `mp_eligible_games`,
count(distinct case when is_classroom_game AND game_type = 'flashcard_async' then game_id end) as `flashcard_async`,
count(distinct case when is_classroom_game AND game_type = 'test' then game_id end) as `test`,
count(distinct case when is_classroom_game AND game_type = 'tp' then game_id end) as `tp`,
count(distinct case when is_classroom_game AND game_type in ('mystic_peak','mastery_peak') then game_id end) as `mystic_peak`,
count(distinct case when is_classroom_game AND game_type = 'team' then game_id end) as `team`,
count(distinct case when is_classroom_game AND game_type = 'async' then game_id end) as `async`,
count(distinct case when is_classroom_game AND game_type = 'live' then game_id end) as `live`,
count(distinct case when is_classroom_game AND game_type = 'challenge' then game_id end) as `challenge`,
count(distinct case when is_classroom_game AND game_type = 'tp_offline' then game_id end) as `tp_offline`,
count(distinct case when is_classroom_game AND game_type = 'pres_async' then game_id end) as `pres_async`,
count(distinct case when is_classroom_game AND game_type = 'pres_tp' then game_id end) as `pres_tp`,
FROM new_ff A
LEFT JOIN clean.game B
ON A.user_id = B.host_id
AND DATE(B.created_at) >= '2025-09-01'
AND A.dt = DATE(B.created_at)
GROUP BY 1