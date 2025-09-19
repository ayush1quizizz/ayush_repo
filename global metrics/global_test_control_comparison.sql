WITH new_ff as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-07' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'delivery-global-control'
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)

select distinct 
       a.dt,
       a.experiment_id,
       a.variation_id,
       count(distinct a.user_id) as users,
       count(distinct g.game_id) as games,
       count(distinct g.host_id) as hosts,
       count(distinct case when g.is_classroom_game = true then g.host_id end) as mg_hosts,
       count(distinct case when g.is_classroom_game = true then g.game_id end) as mg_games,
from new_ff a
left join clean.game g
on a.user_id = g.host_id
and a.dt = date(g.created_at)
and date(g.created_at) >= '2025-09-07'
and is_classroom_game = true
and host_country = 'US'
and host_occupation = 'teacher'
group by 1,2,3
order by 1,2,3