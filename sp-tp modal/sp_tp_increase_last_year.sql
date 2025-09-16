with no_tp_hosts as (
select distinct host_id,case when games > 0 then 'tp_exposed' else 'no_tp_exposed' end as has_tp_games
from (
select host_id, 
       count(distinct case when game_type in ('tp','pres_tp') then game_id end) as games
from clean.game g
where date(g.created_at) >= '2024-01-01'
and date(g.created_at) <= '2024-08-24'
and g.host_occupation = 'teacher'
and g.host_country = 'US'
and g.is_classroom_game
--and g.game_type in ('tp','pres_tp')
group by 1
order by 2
)
--where games > 0
)

,base as (
select g.host_id,
       count(distinct case when g.game_type in ('tp','pres_tp') then g.game_id end) as tp_games
from clean.game g
left join no_tp_hosts n
on g.host_id = n.host_id
where date(g.created_at) >= '2024-08-25'
and date(g.created_at) <= '2024-08-29'
and g.host_occupation = 'teacher'
and g.host_country = 'US'
and g.is_classroom_game
--and g.game_type in ('tp','pres_tp')
and (n.has_tp_games = 'no_tp_exposed' or n.host_id is null)
group by 1
order by 2
)

,pre_games as (
select b.host_id,
       case when b.tp_games > 0 then 'tp_acquired' else 'no_tp_acquired' end as tp_status,
       'pre_games' as time_period,
       count(distinct game_id) as games
from base b 
left join clean.game g
on b.host_id = g.host_id
and date(g.created_at) >= '2024-08-18'
and date(g.created_at) <= '2024-08-22'
and g.host_occupation = 'teacher'
and g.host_country = 'US'
and g.is_classroom_game
--where b.tp_games > 0
group by 1,2,3
--and g.game_type in ('tp','pres_tp')
)

,post_games as (
select b.host_id,
       case when b.tp_games > 0 then 'tp_acquired' else 'no_tp_acquired' end as tp_status,
       'post_games' as time_period,
       count(distinct game_id) as games
from base b
left join clean.game g
on b.host_id = g.host_id
and date(g.created_at) >= '2024-09-01'
and date(g.created_at) <= '2024-09-05'
and g.host_occupation = 'teacher'
and g.host_country = 'US'
and g.is_classroom_game
--where b.tp_games > 0
group by 1,2,3
)
select count(distinct case when tp_status = 'tp_acquired' then host_id end) as tp_acquired_hosts,
       count(distinct case when tp_status = 'no_tp_acquired' then host_id end) as no_tp_acquired_hosts,
       count(distinct host_id) as total_hosts,
       sum(case when time_period = 'pre_games' and tp_status = 'tp_acquired' then games end) as pre_games_tp_games,
       sum(case when time_period = 'pre_games' and tp_status = 'no_tp_acquired' then games end) as pre_games_no_tp_games,
       sum(case when time_period = 'post_games' and tp_status = 'tp_acquired' then games end) as post_games_tp_games,
       sum(case when time_period = 'post_games' and tp_status = 'no_tp_acquired' then games end) as post_games_no_tp_games,
from (
select * from pre_games
union all
select * from post_games
)


