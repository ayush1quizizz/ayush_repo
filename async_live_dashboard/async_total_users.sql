select count(distinct g.host_id) as total_users
from clean.game g 
inner join clean.user u
on g.host_id = u.user_id
where date(g.created_at) >= '2025-09-07'
and date(g.created_at) <= '2025-09-13'
and g.game_type in ('async','pres_async','flashcard_async')
and u.occupation = 'teacher'
and u.country = 'US'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and g.is_classroom_game