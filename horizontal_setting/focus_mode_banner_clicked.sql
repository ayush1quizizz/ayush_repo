WITH new_ff as (
select distinct 
       ff.user_id,
       date(ff.experiment_date) as dt,
       variation_id,
       experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-03'
 AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'game_setting_v3'
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)


SELECT 
--dt,
variation_id,touchpoint,count(distinct host_id) as hosts
FROM (
SELECT DISTINCT
--A.dt,
variation_id,
B.host_id,
CASE WHEN ca.user_id is not null and cb.option = 'focusMode' then 'both_tab_banner_clicked'
     WHEN ca.user_id is not null then 'gamesettings_tab_changed'
     WHEN cb.option = 'focusMode' then 'horizontal_focus_mode_theme_clicked'
     ELSE 'none'
     END as touchpoint,
    
FROM new_ff A
INNER JOIN clean.game B
ON A.user_id = B.host_id
AND DATE(B.created_at) >= '2025-09-01'
AND A.dt = DATE(B.created_at)
AND B.is_classroom_game IS TRUE
AND B.is_focus_mode IS TRUE
LEFT JOIN track.gamesettings_tab_changed AS ca ON B.host_id = ca.user_id AND DATE(B.created_at) = DATE(ca.created_at)
LEFT JOIN track.game_setting_anti_cheating_clicked AS cb ON B.host_id = cb.user_id AND DATE(B.created_at) = DATE(cb.created_at)
WHERE A.variation_id = 'ENABLED'
)
group by 1,2