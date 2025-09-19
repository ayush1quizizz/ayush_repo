WITH base as (
select distinct 
      ff.user_id,
      date(ff.experiment_date) as dt, 
      variation_id,
      experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-07' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id in (
'delivery-global-control'
)
--and variation_id = 'CONTROL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
order by 2
)

--select dt,count(distinct user_id) as users
-- from base
-- group by 1
-- order by 2 desc
--,games as (
SELECT a.variation_id,
       count(distinct g.host_id) as hosts,
       count(distinct case when g.is_classroom_game = true then g.host_id end) as mg_hosts,
       count(distinct g.game_id) as games,
       count(distinct case when g.is_classroom_game = true then g.game_id end) as mg_games,
       count(distinct case when g.is_classroom_game = true and game_type in ('tp','pres_tp') then g.game_id end) as mg_tp_games,
       count(distinct case when g.is_classroom_game = true and game_type in ('async','pres_async','flashcard_async') then g.game_id end) as mg_async_games,
       count(distinct case when g.is_classroom_game = true and game_type in ('test') then g.game_id end) as mg_tests_hosts,
       count(distinct case when g.is_classroom_game = true and game_type in ('live') then g.game_id end) as mg_live_games,
       count(distinct case when g.is_classroom_game = true and game_type in ('team') then g.game_id end) as mg_team_games,
       count(distinct case when g.is_classroom_game = true and game_type in ('mystic_peak','mastery_peak') then g.game_id end) as mg_mastery_peak_games,
FROM base a 
inner join clean.game g
on a.user_id = g.host_id
and a.dt = date(g.created_at)
and date(g.created_at) >= '2025-09-07'
and date(g.created_at) < current_date()
group by 1
--)

