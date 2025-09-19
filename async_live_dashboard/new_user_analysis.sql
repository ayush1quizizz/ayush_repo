WITH new_ff as (
select distinct ff.user_id,
      date(ff.experiment_date) as dt, 
      variation_id,
      case when date(ff.experiment_date) = date(u.created_at) then 'same_day_reg_user' else 'other_day_reg_user' end as user_type
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-07' 
AND date(ff.experiment_date) < '2025-09-15'
AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'async-live-new-users'
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)
--,user_tagging as (
-- select familiarity_with_quizizz,
--        count(distinct user_id) as users,
-- FROM(
SELECT
A.dt,
A.variation_id, 
--A.user_type,
case when u.onboarding_question.familiarity_with_quizizz in ('changed_school','high_frequently_used','less_frequently_used','familiar_with_quizizz') then 'familiarity_with_quizizz' 
     when u.onboarding_question.familiarity_with_quizizz in ('first_time','new_to_quizizz') then 'new_to_quizizz'
     else u.onboarding_question.familiarity_with_quizizz
end as familiarity_with_quizizz,
COUNT(DISTINCT a.user_id) as users, 
COUNT(DISTINCT host_id) as hosts, 
COUNT(DISTINCT CASE WHEN is_classroom_game THEN host_id END) AS mg_hosts, 
COUNT(DISTINCT game_id) as games, 
COUNT(DISTINCT CASE WHEN is_classroom_game THEN game_id END) as mg_games
FROM new_ff A   
LEFT JOIN clean.game B
ON A.user_id = B.host_id
AND DATE(B.created_at) >= '2025-09-01'
AND A.dt = DATE(B.created_at)
INNER JOIN clean.user u
ON A.user_id = u.user_id
GROUP BY 1,2,3
ORDER BY 1,2,3
-- )
-- group by 1