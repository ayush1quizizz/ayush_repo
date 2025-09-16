WITH base as (
select distinct 
       ff.user_id,
       date(ff.experiment_date) as dt,
       CASE WHEN variation_id in ('DISABLED','PACING_MODAL') THEN 'CONTROL' ELSE variation_id END as variation_id,
       --variation_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(experiment_date) >= '2025-09-01'
and date(experiment_date) < '2025-09-08'
--and date(g.created_at) = date(experiment_date)
and ff.experiment_id = 'session-setup-experiment'

--and variation_id = 'PACING_MODAL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
--AND u.country <> 'BR'
and u.occupation = 'teacher'
)
SELECT DATE(A.dt) AS Date, 
       variation_id, 
    --    COUNT(DISTINCT A.user_id) AS users, 
    --    COUNT(DISTINCT B.host_id) AS hosts, 
    --    COUNT(DISTINCT B.game_id) AS games,
    --    COUNT(DISTINCT CASE WHEN B.is_classroom_game THEN B.host_id END) AS mg_hosts,
    --    COUNT(DISTINCT CASE WHEN B.is_classroom_game THEN B.game_id END) AS mg_games,
    --    AVG(DISTINCT CASE WHEN B.is_classroom_game THEN ga.players END) AS mg_players_per_game,
    --    AVG(DISTINCT CASE WHEN B.is_classroom_game THEN ga.responses END) AS mg_responses_per_game,
    --    AVG(DISTINCT CASE WHEN B.is_classroom_game THEN B.completion_rate END) AS mg_completion_rate,
    --    AVG(DISTINCT CASE WHEN B.is_classroom_game THEN B.accuracy END) AS mg_accuracy,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Live' THEN B.game_id END) AS live_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Homework' THEN B.game_id END) AS hw_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Live' AND game_type LIKE '%tp%' THEN B.game_id END) AS live_tp_games,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Live' AND game_type NOT LIKE '%tp%' THEN B.game_id END) AS live_sp_games,

FROM base A
LEFT JOIN clean.game B
ON A.user_id = B.host_id
--AND is_classroom_game
AND DATE(B.created_at) >= '2025-09-01'
AND DATE(A.dt) = DATE(B.created_at)
LEFT JOIN 
(select game_id,
        count(distinct session_id) as players,
        count(distinct responses) as responses 
from clean.game_attempt 
where DATE(game_created_at) >= '2025-09-01'
group by 1) ga
ON B.game_id = ga.game_id

GROUP BY 1,2
ORDER BY 1,2