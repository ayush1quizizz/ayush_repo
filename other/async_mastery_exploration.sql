select 
      (extract(year from date(g.created_at))) as yr,
      (extract(week from date(g.created_at))) as wk,
      count(distinct game_id) as total_games,
      count(distinct case when coalesce(mastery_mode_goal,mystic_peak_goal) is not null then game_id end) as mastery_games,
      -- g.mastery_mode_goal,
      -- g.mystic_peak_goal
from clean.game g
inner join clean.user u
on g.host_id = u.user_id
where game_type = 'async'
and date(g.created_at) >= '2024-01-01'
and u.occupation = 'teacher'
and u.country = 'US'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'            
group by 1,2
order by 1 