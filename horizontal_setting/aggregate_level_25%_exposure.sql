WITH new_ff as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-09' 
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
--A.dt,
variation_id,
COUNT(DISTINCT user_id) as users,
COUNT(DISTINCT host_id) as hosts,
COUNT(DISTINCT CASE WHEN is_classroom_game THEN host_id END) AS mg_hosts,
COUNT(DISTINCT game_id) as games,
COUNT(DISTINCT CASE WHEN is_classroom_game THEN game_id END) AS mg_games,
count(distinct case when is_classroom_game AND is_accommodations_used = true then game_id end) as accom_games_2,
count(distinct case when is_classroom_game AND is_assigned = true then game_id end) as assigned_games,
count(distinct case when is_classroom_game AND game_type = 'flashcard_async' then game_id end) as `flashcard_async`,
count(distinct case when is_classroom_game AND game_type = 'test' then game_id end) as `test`,
count(distinct case when is_classroom_game AND game_type = 'tp' then game_id end) as `tp`,
count(distinct case when is_classroom_game AND game_type = 'mystic_peak' then game_id end) as `mystic_peak`,
count(distinct case when is_classroom_game AND game_type = 'team' then game_id end) as `team`,
count(distinct case when is_classroom_game AND game_type = 'async' then game_id end) as `async`,
count(distinct case when is_classroom_game AND game_type = 'live' then game_id end) as `live`,
count(distinct case when is_classroom_game AND game_type = 'challenge' then game_id end) as `challenge`,
count(distinct case when is_classroom_game AND game_type = 'tp_offline' then game_id end) as `tp_offline`,
count(distinct case when is_classroom_game AND game_type = 'pres_async' then game_id end) as `pres_async`,
count(distinct case when is_classroom_game AND game_type = 'pres_tp' then game_id end) as `pres_tp`,
COUNT(DISTINCT CASE WHEN is_adaptive IS TRUE AND is_classroom_game THEN game_id END ) AS question_bank,
COUNT(DISTINCT CASE WHEN is_ai_answer_explanation IS TRUE AND is_classroom_game THEN game_id END ) AS is_ai_answer_explanation,
COUNT(DISTINCT CASE WHEN attempts_permitted <> 0 AND is_classroom_game THEN game_id END ) AS attempts_changed,
COUNT(DISTINCT CASE WHEN is_leaderboard_shown IS TRUE AND is_classroom_game THEN game_id END ) AS is_leaderboard_shown,
COUNT(DISTINCT CASE WHEN skip_question IS TRUE AND is_classroom_game THEN game_id END ) AS is_skip_ques_enabled,
COUNT(DISTINCT CASE COALESCE(mastery_mode_goal,mystic_peak_goal) IS NOT NULL AND is_classroom_game THEN game_id END ) AS is_mastery_mode ,
COUNT(DISTINCT CASE WHEN is_duel_enabled IS TRUE AND is_classroom_game THEN game_id END ) AS is_strike_and_shield,
COUNT(DISTINCT CASE WHEN timer != 'off' AND is_classroom_game THEN game_id END ) AS is_timer_on,
COUNT(DISTINCT CASE WHEN is_redemption IS TRUE AND is_classroom_game THEN game_id END ) AS is_redemption_qus_enabled,
COUNT(DISTINCT CASE WHEN is_powerups_enabled IS TRUE AND is_classroom_game THEN game_id END ) AS is_powerups_enabled,
COUNT(DISTINCT CASE WHEN is_meme_shown IS TRUE AND is_classroom_game THEN game_id END ) AS is_meme_shown,
COUNT(DISTINCT CASE WHEN is_quiz_jumbled IS TRUE AND is_classroom_game THEN game_id END ) AS shuffle_qus_enabled,
COUNT(DISTINCT CASE WHEN is_student_live_reaction_enabled IS TRUE AND is_classroom_game THEN game_id END ) AS student_live_reaction,
COUNT(DISTINCT CASE WHEN is_answer_shown <> 'always' AND is_classroom_game THEN game_id END ) AS is_answer_not_shown,
COUNT(DISTINCT CASE WHEN is_focus_mode IS TRUE AND is_classroom_game THEN game_id END ) AS is_focus_mode,
COUNT(DISTINCT CASE WHEN is_review_and_submit IS TRUE AND is_classroom_game THEN game_id END ) AS is_review_and_submit,
COUNT(DISTINCT CASE WHEN is_nickname_generated IS TRUE AND is_classroom_game THEN game_id END ) AS is_nickname_generated,
COUNT(DISTINCT CASE WHEN are_answers_jumbled IS TRUE AND is_classroom_game THEN game_id END ) AS are_answers_jumbled,
COUNT(DISTINCT CASE WHEN is_no_frills IS TRUE AND is_classroom_game THEN game_id END ) AS serious_games,
count(distinct case when is_schedule_later = true and is_classroom_game then game_id end) as is_schedule_later,
count(distinct case when is_quiz_without_correct_answers = true and is_classroom_game then game_id end) as is_quiz_without_correct_answers,
FROM new_ff A
LEFT JOIN clean.game B
ON A.user_id = B.host_id
AND DATE(B.created_at) >= '2025-09-01'
AND A.dt = DATE(B.created_at)
GROUP BY 1