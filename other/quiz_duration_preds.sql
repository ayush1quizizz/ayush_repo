with

quiz_median as (
  select distinct
    A.quiz_id,
    B.questions,
    count(distinct game_id) over (partition by A.quiz_id) as num_games,
    count(distinct host_id) over (partition by A.quiz_id) as num_hosts,
    round(percentile_disc(date_diff(ended_at, started_at, second), 0.5) 
      over (partition by A.quiz_id), 0) as duration_median,
  from `quizizz-org.delivery.sf_games_quiz` A
  left join `quizizz-org.delivery.sf_quiz_quiz` B
    on A.quiz_id = B.quiz_id
  qualify round(percentile_disc(date_diff(ended_at, started_at, second), 0.5) 
      over (partition by quiz_id), 0) > 0
),

final as (
  select 
    A.quiz_id,
    B.num_games,
    B.questions,
    B.duration_median,
    A.duration_calc,
    round(case when duration_median > 0 and num_games >= 5 and A.duration_calc > 0 and abs((duration_median/duration_calc) - 1) <= 0.5 
                then duration_median 
                else duration_calc end, 0) as duration_pred,
  from `quizizz-org.delivery.sf_quiz_duration_calc` A
  left join quiz_median B
    on A.quiz_id = B.quiz_id
  order by num_games desc
)

select *
from final
order by 2 desc