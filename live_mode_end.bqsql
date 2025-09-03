with base as (
select distinct 
       g.host_id,
       g.is_leaderboard_shown,
       en.user_id,
from clean.game g 
left join track.game_end_confirmed en
on g.host_id = en.user_id
where date(g.created_at) BETWEEN '2025-02-01' and '2025-04-30'
and g.host_occupation = 'teacher'
and g.host_country = 'US'
and g.is_classroom_game
and g.game_type_group = 'Live'
and g.quiz_type = 'quiz'
)

select count(distinct host_id) as total_users,
       count(distinct case when is_leaderboard_shown then host_id end) as leaderboard_shown_users,
       count(distinct user_id) as end_users
from base 