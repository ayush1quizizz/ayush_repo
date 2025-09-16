-- final table with durations for iv and lessons, to be used in superformat adp

with

quiz_iv_lessons as (
  select 
    quiz_id,
    created_by,
    quiz_type,
    coalesce(slides, 0) as slides,
    coalesce(questions, 0) as questions,
    round(coalesce(video_metadata.duration, 0), 0) as video_duration,
  from `quizizz-org.clean.quiz`
  where true
    and (
          (quiz_type = 'presentation' and slides > 0)
      or (quiz_type = 'video-quiz' and video_metadata.duration > 0)
    )
),

user as (
  select user_id,
  from `clean.user`
  where country = 'US'
    and occupation = 'teacher'
    and is_false_teacher = false
),

game_iv_lessons as (
  select game_id,
    A.quiz_id,
    quiz_type,
    host_id,
    started_at,
    ended_at,
    game_type,
  from `quizizz-org.clean.game` A 
  inner join user B
    on A.host_id = B.user_id
  where is_classroom_game = true 
      and (
          (quiz_type = 'video-quiz' and game_type in ('pres_tp', 'tp', 'live'))
          or (quiz_type = 'presentation' and game_type = 'pres_tp')
      )
      and game_state <> 'running'
      -- and timestamp_diff(ended_at, started_at, second) between 5*60 and 60*60
),

iv_lessons as (
  select distinct
    A.quiz_id,
    A.slides, 
    A.questions,
    A.video_duration,
     
    count(distinct B.game_id) over (partition by A.quiz_id) as num_games,
    count(distinct B.host_id) over (partition by A.quiz_id) as num_hosts,
    
    round(percentile_disc(date_diff(ended_at, started_at, second), 0.5) 
      over (partition by A.quiz_id), 0) as duration_median,
    
    case when A.quiz_type = 'presentation' then round(1.72*60*A.slides + 0.515*60*A.questions, 0)
         when A.quiz_type = 'video-quiz' then round(1.56*A.video_duration + 0.564*60*A.questions, 0) end
         as duration_calc,

  from quiz_iv_lessons A
  left join game_iv_lessons B
    on A.quiz_id = B.quiz_id
    and A.created_by <> B.host_id
),

preds as (
  select *,
    round(case when duration_median > 0 and num_games >= 5 and abs((duration_median/duration_calc) - 1) <= 0.5 
                then duration_median 
                else duration_calc end, 0) as duration_pred,
  from iv_lessons
)

select *
from preds