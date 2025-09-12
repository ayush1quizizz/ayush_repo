WITH base as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-08-01' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id in (
'delivery-global-control'
)
and variation_id = 'CONTROL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
order by 2
)

-- select dt,count(distinct user_id) as users
-- from base
-- group by 1
-- order by 2 desc


select 
       EXTRACT(YEAR FROM date(b.dt)) as year,
       EXTRACT(MONTH FROM date(b.dt)) as month,
       date(b.dt) as dt,
       --quiz_type,
       count(distinct b.user_id) as users,
       count(distinct g.host_id) as hosts,
       count(distinct g.game_id) as games,
       count(distinct case when g.is_classroom_game = true then g.host_id end) as mg_hosts,
       count(distinct case when g.is_classroom_game = true then g.game_id end) as mg_games,
       count(distinct case when g.is_classroom_game = true and game_type_group = 'Live' then g.game_id end) as mg_lv_games,
       count(distinct case when g.is_classroom_game = true and game_type_group = 'Homework' then g.game_id end) as mg_hw_games,
       count(distinct case when g.is_classroom_game = true and quiz_type = 'quiz' then g.game_id end) as mg_quiz_games,
       count(distinct case when g.is_classroom_game = true and quiz_type = 'presentation' then g.game_id end) as mg_lesson_games,
       count(distinct case when g.is_classroom_game = true and quiz_type = 'reading-quiz' then g.game_id end) as mg_passage_games,
       count(distinct case when g.is_classroom_game = true and quiz_type = 'flashcard' then g.game_id end) as mg_flashcard_games,
       count(distinct case when g.is_classroom_game = true and quiz_type = 'video-quiz	' then g.game_id end) as mg_interactive_video_games,
FROM base b 
left join clean.game g
on b.user_id = g.host_id
and b.dt = date(g.created_at)
and date(g.created_at) >= '2025-08-01'
and g.is_classroom_game = true
and g.host_country = 'US'
and g.host_occupation = 'teacher'
group by 1,2,3
order by 4 desc