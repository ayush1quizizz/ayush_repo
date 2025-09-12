WITH base as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(experiment_date) >= '2025-08-21'
--and date(g.created_at) = date(experiment_date)
and date(experiment_date) < current_date()
and ff.experiment_id = 'session-setup-experiment'
and variation_id = 'PACING_MODAL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
--AND u.country <> 'BR'
and u.occupation = 'teacher'
),

games AS
(
SELECT created_at, game_id, host_id, game_type_group, game_type,
CASE
WHEN game_type IN ('async', 'flashcard_async', 'pres_async') THEN 'async'
WHEN game_type IN ('tp', 'pres_tp') THEN 'tp'
ELSE game_type
END AS game_type_consolidated
FROM clean.game
WHERE is_classroom_game AND DATE(created_at) >= '2025-08-21'
)

SELECT variation_id, COUNT(DISTINCT host_id) AS hosts, 
       sum(game_modes) as game_modes
-- COUNT(DISTINCT CASE WHEN game_modes > 1 THEN host_id END) AS multiple_game_mode_hosts
FROM
(
SELECT variation_id,
host_id, COUNT(DISTINCT game_type_consolidated) AS game_modes


FROM base A
LEFT JOIN games B
ON A.user_id = B.host_id
AND DATE(A.dt) = DATE(B.created_at)
GROUP BY 1,2
)
GROUP BY 1
ORDER BY 1
