--async live dashboard funnel :
with base as (
select distinct ff.user_id,date(ff.experiment_date) as dt,variation_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(experiment_date) >= '2025-09-09'
and date(experiment_date) < current_date()
--and date(g.created_at) = date(experiment_date)
and ff.experiment_id = 'session-setup-experiment'
--and variation_id = 'DISABLED'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)
-- select dt,variation_id,count(distinct user_id) as users
-- from base
-- group by 1,2
-- order by 1,2 
-- ,below_base as (
-- select distinct ff.user_id,date(ff.experiment_date) as dt
-- from transformed.user_feature_flag_map_most_frequent_in_a_day ff
-- inner join clean.user u
-- on ff.user_id = u.user_id
-- where date(experiment_date) between '2025-08-22' and '2025-08-29'
-- --and date(g.created_at) = date(experiment_date)
-- and ff.experiment_id = 'async-live-dash-redirect'
-- and variation_id = 'ENABLED'
-- and u.email not like '%quizizz.com'
-- and u.email not like '%wayground.com'
-- and u.country = 'US'
-- and u.occupation = 'teacher'
-- )
-- ,base as (
-- select distinct a.*
-- from top_base a
-- inner join below_base b
-- on a.user_id = b.user_id
-- and a.dt = b.dt
-- )
,adp_base as (
select distinct
qp.user_id,
qp.created_at,
q.quiz_id,
q.quiz_type
from track.quiz_pageview qp
-- on a.user_id = qp.user_id
-- and date(a.dt) = date(qp.created_at) and date(qp.created_at) >= '2025-08-05'
inner join clean.quiz q
on REGEXP_EXTRACT(qp.url, r'^/admin/[^/]+/([^/]+)(?:/|$)') = q.quiz_id
and q.quiz_type = 'quiz'
where date(qp.created_at) >= '2025-08-12'
)
,time_base as (
select game_id,
round((sum(timestamp_diff(lead_time,created_at,second))*(1.0)/60),0) as total_time_in_min
from (
select game_id,
created_at,
SAFE_CAST(coalesce(no_of_players,'0') AS INT64) as no_of_players,
lead(created_at,1) over(partition by game_id order by created_at) as lead_time
from track.async_joinlobby_heartbeat_event
where date(created_at) >= '2025-08-12'
and SAFE_CAST(coalesce(no_of_players,'0') AS INT64) >= 1
order by 1,2
)
where lead_time is not null
and timestamp_diff(lead_time,created_at,second) <= 60
group by 1
order by 2 desc
)
-- ,pr_base AS (
--   SELECT total_time_in_min, PERCENT_RANK() OVER (ORDER BY total_time_in_min) AS pr
--   FROM time_base
-- )
select 
--a.dt,
count(distinct a.user_id) as async_dashboard_test_users,
-- count(distinct qp.user_id) as adp_land_users,
-- --count(distinct qp.user_id) as adp_land_users,
-- count(distinct hw.user_id) as game_settings_land_users,
--count(distinct st.user_id) as start_click_users,
count(distinct g.host_id) as total_hosts,
count(distinct g.game_id) as total_games,
count(distinct case when g.is_classroom_game then g.host_id end) as meaningful_hosts,
count(distinct case when g.is_classroom_game then g.game_id end) as meaningful_games,
count(distinct case when g.is_classroom_game then sps.game_id end) as suggested_project_games,
count(distinct case when g.is_classroom_game then spok.game_id end) as suggested_project_okay_games,
count(distinct case when g.is_classroom_game then spc.game_id end) as suggested_project_cancelled_games,
--  count(distinct case when lms.action = 'copyLink' then lms.game_id end) as copy_link_games,
--  count(distinct case when lms.action = 'copyCode' then lms.game_id end) as copy_code_games,
count(distinct case when g.is_classroom_game then jl.game_id end) as async_copy_join_link_games,
count(distinct case when rp.source = 'Join_Screen' then rp.game_id end) as report_page_join_screen_games,
count(distinct case when g.is_classroom_game then alp.game_id end) as leaderboard_page_shown,
--count(distinct case when rp.source = 'Join_Screen' then rp.game_id end) as report_page_join_screen_games,
--count(distinct en.game_id ) as student_login_enabled_games,
count(distinct case when g.is_classroom_game then cc.game_id end) as join_code_copied_leaderboard_pg_games,
count(distinct case when g.is_classroom_game then jc.game_id end) as join_link_copied_leaderboard_pg_games,
count(distinct case when g.is_classroom_game then lrp.game_id end) as report_clicked_leaderboard_pg_games,
count(distinct case when g.is_classroom_game then pp.game_id end) as project_protip_cancelled_games,
count(distinct case when g.is_classroom_game then ac.game_id end) as sort_accuracy_clicked_games,
count(distinct case when tb.total_time_in_min >= 5 and g.is_classroom_game then tb.game_id end) as time_spent_more_than_5_min,
count(distinct case when tb.total_time_in_min >= 2 and g.is_classroom_game then tb.game_id end) as time_spent_more_than_2_min,
count(distinct case when tb.total_time_in_min >= 5 and g.is_classroom_game then tb.game_id end) as hosts_time_spent_more_than_5_min,
count(distinct case when tb.total_time_in_min >= 2 and g.is_classroom_game then tb.game_id end) as hosts_time_spent_more_than_2_min
from base a
-- left join adp_base qp
-- on a.user_id = qp.user_id
-- and date(a.dt) = date(qp.created_at)
-- left join track.homework_game_settings_pageview hw
-- on qp.user_id = hw.user_id
-- and date(qp.created_at) = date(hw.created_at)
-- and qp.quiz_id =  REGEXP_EXTRACT(hw.url, r'^/?admin/[^/]+/[^/]+/([^/]+)(?:/|$)')
-- left join track.game_settings_continue_cta_clicked st
-- on hw.user_id = st.user_id
-- and date(hw.created_at) = date(st.created_at)
-- and REGEXP_EXTRACT(hw.url, r'^/?admin/[^/]+/[^/]+/([^/]+)(?:/|$)')  = st.quiz_id
-- and st.broad_type = 'quiz'
-- and st.game_type = 'async'
left join clean.game g
on a.user_id = g.host_id
--and REGEXP_EXTRACT(hw.url, r'^/?admin/[^/]+/[^/]+/([^/]+)(?:/|$)') = g.quiz_id
and date(a.dt) = date(g.created_at)
and date(g.created_at) >= '2025-08-12'
and g.quiz_type = 'quiz'
and g.game_type = 'async'
-- and g.is_classroom_game
left join track.Suggested_Project_Screen_Shown sps
on g.game_id = sps.game_id
left join track.Suggested_Project_Screen_Okay spok
on g.game_id = spok.game_id
left join track.Suggested_Project_Screen_Cancelled spc
on g.game_id = spc.game_id
left join track.GameLinkShareLMS lms
on g.game_id = lms.game_id
left join track.async_screen_copy_join_link_clicked jl
on g.game_id = jl.game_id
left join track.async_report_page_clicked rp
on g.game_id = rp.game_id
-- left join track.enable_student_login_toggled en
-- on g.game_id = en.game_id
left join track.async_leaderboard_pageview alp
on g.game_id = alp.game_id
left join track.async_leaderboard_screen_join_code_copied cc
on g.game_id = cc.game_id
left join track.async_leaderboard_screen_join_link_copied jc
on g.game_id = jc.game_id
left join track.async_leaderboard_screen_report_clicked lrp
on g.game_id = lrp.game_id
left join track.project_protip_cancelled pp
on g.game_id = pp.game_id
left join track.async_leaderboard_questions_tab_sort_by_accuracy_clicked ac
on g.game_id = ac.game_id
left join time_base tb
on g.game_id =tb.game_id
--group by 1
order by 1


--and g.is_classroom_game
-- select distinct button
-- from track.adp_page_start_now_modal_selection











































































































































































































































































































































































































































































































































































































































































































































































































































































