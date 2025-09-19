with ai_games as (
select distinct 
       q.subject,
       g.game_id,
       g.host_id,
       g.created_at
    --    count(distinct game_id) as games,
    --    count(distinct case when is_ai_answer_explanation = true then game_id end) as ai_games,
from clean.game g
left join clean.quiz q
on g.quiz_id = q.quiz_id
where date(g.created_at) >= '2025-08-01'
and date(g.created_at) < '2025-09-01'
and host_occupation = 'teacher'
and host_country = 'US'
and is_classroom_game = true
and is_ai_answer_explanation = true
)

select distinct 
       a.subject,
       a.game_id,
       a.host_id,
       a.created_at,
       g.game_id as next_game_id,
       g.host_id as next_host_id,
       g.created_at as next_created_at
from ai_games a
left join clean.game g
on a.host_id = g.host_id
and date(g.created_at) > date(a.created_at)
and is_classroom_game = true
-- left join clean.quiz q
-- on g.quiz_id = q.quiz_id
-- and a.subject = q.subject
--group by 1
--order by 2 desc