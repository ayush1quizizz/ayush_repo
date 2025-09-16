---completion rate and reattempt rate metric (vs_completion_and_reattempt)
WITH base_cr_rr AS
(SELECT
DATE(DATE_TRUNC(game_created_at, MONTH)) AS mnth,
DATE(DATE_TRUNC(game_created_at, WEEK)) AS wk,
DATE(game_created_at) AS dt,
CASE WHEN host_country IN ('US') THEN 'US' ELSE 'ROW' END AS host_country,
g.game_id,
g.game_type,
gp.session_id,
attempts_permitted,
CASE WHEN mastery_mode_goal IS NOT NULL THEN TRUE ELSE FALSE END AS is_mastery_mode,
is_ai_answer_explanation,
CASE WHEN gp.user_id IS NOT NULL THEN 'Loggedin'
     ELSE 'Non- Loggedin' END AS logged_in,
MAX(session_attempt_index) AS session_attempt_index,
MAX(CASE WHEN session_attempt_index=1 THEN gp.questions_attempted END) AS first_attempt_questions_attempted,
SUM(gp.questions_attempted) AS questions_attempted,
MAX(q.questions) AS questions
FROM `quizizz-org.clean.game_attempt` gp
INNER JOIN  `quizizz-org.clean.game` g
ON gp.game_id=g.game_id
INNER JOIN `quizizz-org.clean.quiz` q
ON g.quiz_id=q.quiz_id
WHERE host_occupation = 'teacher' --AND host_country='US'
AND DATE(g.created_at) >=  CURRENT_DATE - 7 
AND DATE(game_created_at) >=  CURRENT_DATE - 7 
AND g.players>1 AND g.responses>0
AND g.game_type_group in ('Live','Homework')
AND FORMAT_DATE('%a', DATE(g.created_at)) NOT IN ('Sat','Sun')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11
)

, base_cr_rr_final AS (
SELECT
mnth,
wk,
dt,
game_id,
logged_in,
is_mastery_mode,
is_ai_answer_explanation,
game_type,
host_country,
COUNT(DISTINCT CASE WHEN attempts_permitted NOT IN (1) THEN session_id END) AS repeat_eligible_students,
COUNT(DISTINCT CASE WHEN session_attempt_index>1 THEN session_id END) AS repeat_students,
COUNT(DISTINCT CASE WHEN session_attempt_index=2 THEN session_id END) AS second_attempt_students,
COUNT(DISTINCT CASE WHEN session_attempt_index=3 THEN session_id END) AS third_attempt_students,
COUNT(DISTINCT CASE WHEN session_attempt_index>3 THEN session_id END) AS fourth_and_above_attempt_students,
SUM(first_attempt_questions_attempted) AS first_attempt_questions_attempted,
SUM(questions_attempted) AS questions_attempted,
SUM(questions) AS game_questions
FROM base_cr_rr
GROUP BY 1,2,3,4,5,6,7,8,9
)

SELECT 
mnth,
wk,
dt,
game_type,
is_mastery_mode,
is_ai_answer_explanation,
host_country,
logged_in,
COUNT(DISTINCT game_id) AS games,
SUM(repeat_eligible_students) AS repeat_eligible_students,
SUM(repeat_students) AS repeat_students,
SUM(second_attempt_students) AS second_attempt_students,
SUM(third_attempt_students) AS third_attempt_students,
SUM(fourth_and_above_attempt_students) AS fourth_and_above_attempt_students,
SUM(first_attempt_questions_attempted) AS first_attempt_questions_attempted,
SUM(questions_attempted) AS questions_attempted,
SUM(game_questions) AS game_questions
FROM base_cr_rr_final
GROUP BY 1,2,3,4,5,6,7,8