WITH base as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,

from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
left join clean.game g
on ff.user_id = g.host_id
and date(g.created_at) < '2025-08-25' and date(g.created_at) >= '2024-08-01'
and g.game_type in ('tp','pres_tp')
where date(experiment_date) >= '2025-08-25'
--and date(g.created_at) = date(experiment_date)
and date(experiment_date) <= '2025-08-29'
and ff.experiment_id = 'session-setup-experiment'
--and variation_id = 'CONTROL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
--AND u.country <> 'BR'
and u.occupation = 'teacher'
and g.host_id is null
)
,tp_acquired as (
select distinct b.user_id
,case when g.host_id is not null then 'tp_acquired' else 'tp_not_acquired' end as tp_status
from base b 
left join clean.game g
on b.user_id = g.host_id
and date(g.created_at) >= '2025-08-25'
and date(g.created_at) <= '2025-08-29'
and g.game_type in ('tp','pres_tp')
--group by 1,2,3
--order by 1,2,3
)

,pre_games as (
select a.tp_status,
        'pre_games' as time_period,
--count(distinct a.user_id) as users,
count(distinct b.host_id) as hosts,
count(distinct b.game_id) as games,
from tp_acquired a
left join clean.game b
on a.user_id = b.host_id
and date(b.created_at) >= '2025-08-18'
and date(b.created_at) <= '2025-08-22'
group by 1,2
order by 1
)

,post_games as (
select a.tp_status,
        'post_games' as time_period,
count(distinct b.host_id) as hosts,
count(distinct b.game_id) as games,
from tp_acquired a
left join clean.game b
on a.user_id = b.host_id
and date(b.created_at) >= '2025-09-01'
and date(b.created_at) <= '2025-09-05'
group by 1,2
order by 1
)

select * from pre_games
union all
select * from post_games

