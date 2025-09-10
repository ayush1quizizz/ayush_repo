select date(g.created_at) as dt,
       count(distinct g.host_id) as hosts,
       count(distinct case when b.user_id is not null then g.host_id end) as teacher_db_tab_hosts,
       count(distinct case when t.user_id is not null then g.host_id end) as tab_switch_alert_dismiss_all_alerts_hosts,
       count(distinct case when t2.user_id is not null then g.host_id end) as tab_switch_alert_remove_hosts,
       count(distinct case when b.user_id is not null then g.game_id end) as teacher_db_tab_games,
       count(distinct case when t.user_id is not null then g.game_id end) as tab_switch_alert_dismiss_all_alerts_games,
       count(distinct case when t2.user_id is not null then g.game_id end) as tab_switch_alert_remove_games
from clean.game g
left join track.teacher_db_tab b 
on g.host_id = b.user_id
and date(g.created_at) = date(b.created_at)
and b.tab_name = 'focusMode'
left join track.tab_switch_alert_dismiss_all_alerts t
on g.host_id = t.user_id
and date(g.created_at) = date(t.created_at)
left join track.tab_switch_alert_remove t2
on g.host_id = t2.user_id
and date(g.created_at) = date(t2.created_at)
where date(g.created_at) >= '2025-09-08'
and g.is_classroom_game = true
and g.is_focus_mode 
and g.host_country = 'US'
and g.host_occupation = 'teacher'
group by 1
order by 1