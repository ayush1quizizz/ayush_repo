with glob_control as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-08-21' 
AND date(ff.experiment_date) < current_date()
and ff.experiment_id = 'delivery-global-control'
--and variation_id = 'CONTROL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)
--,glob_control_games as (
select a.experiment_id,
       a.variation_id,
       count(distinct a.user_id) as users,
       count(distinct b.host_id) as hosts,
       count(distinct b.game_id) as games,
       count(distinct case when b.is_classroom_game then b.host_id end) as mg_hosts,
       count(distinct case when b.is_classroom_game then b.game_id end) as mg_games,
       count(distinct case when b.is_classroom_game and game_type in ('tp','pres_tp') then b.game_id end) as mg_tp_games,
       count(distinct case when b.is_classroom_game and  game_type in ('async','pres_async','flashcard_async') then b.game_id end) as mg_async_games,
       count(distinct case when b.is_classroom_game and  game_type in ('test') then b.game_id end) as mg_tests_hosts,
       count(distinct case when b.is_classroom_game and  game_type in ('live') then b.game_id end) as mg_live_games,
       count(distinct case when b.is_classroom_game and  game_type in ('team') then b.game_id end) as mg_team_games,
       count(distinct case when b.is_classroom_game and  game_type in ('mystic_peak','mastery_peak') then b.game_id end) as mg_mastery_peak_games,
from glob_control a
left join clean.game b
on a.user_id = b.host_id
and a.dt = date(b.created_at)
and date(b.created_at) >= '2025-08-21'
and date(b.created_at) < current_date()
-- and b.is_classroom_game
-- and b.quiz_type = 'presentation'
and b.host_country = 'US'
and b.host_occupation = 'teacher'
group by 1,2
--)

