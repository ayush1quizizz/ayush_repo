--with base as (
select date(a.created_at) as dt,
  count(distinct a.user_id) as users,
       count(distinct c.host_id) as hosts,
from track.game_mode_selected_modal_page a
inner join clean.user b
on a.user_id = b.user_id
left join clean.game c
on a.user_id = c.host_id
and date(c.created_at) < date(a.created_at)
and c.game_type in ('mastery_peak','mystic_peak')
where date(a.created_at) >= '2025-09-08'
and date(a.created_at) < current_date()
and b.occupation = 'teacher'
and b.country = 'US'
and b.email not like '%quizizz.com'
and b.email not like '%wayground.com'
--and c.host_id is null
and a.game_mode = 'mastery_peak'
--)
group by 1
order by 1 desc

