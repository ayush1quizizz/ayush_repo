select distinct g.game_id,gm.game_id,gm.game_mode
from clean.game g
inner join track.ft_game_mode gm
on g.game_id = gm.game_id
where date(g.created_at) >= '2025-09-01'
and date(g.created_at) <= '2025-09-11'
and gm.game_mode is null
--and g.is_classroom_game
and g.host_occupation = 'teacher'
and g.host_country = 'US'
