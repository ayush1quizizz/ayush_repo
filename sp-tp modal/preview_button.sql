WITH new_ff as (
select distinct 
       ff.user_id,
       date(ff.experiment_date) as dt,
       variation_id,
       experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-01' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'session-setup-experiment'
and variation_id = 'PACING_MODAL'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)


-- SELECT dt,
--        variation_id,
--        touchpoint,
--        count(distinct host_id) as hosts
-- FROM (
SELECT 
A.dt,
COUNT(DISTINCT A.user_id) AS total_users,
COUNT(DISTINCT ca.user_id) AS game_settings_preview_button_clicked_users,
COUNT(DISTINCT B.host_id) AS total_hosts,
COUNT(DISTINCT CASE WHEN B.is_classroom_game THEN B.host_id END) AS mg_hosts,
COUNT(DISTINCT B.game_id) AS total_games,
COUNT(DISTINCT CASE WHEN B.is_classroom_game THEN B.game_id END) AS mg_games,
-- COUNT(DISTINCT ca.user_id) AS gamesettings_tab_changed,
--COUNT(DISTINCT CASE WHEN cb.option = 'focusMode' THEN cb.user_id END) AS horizontal_anti_cheating_clicked,
-- COUNT(DISTINCT CASE WHEN cb.option = 'isNoFrills' THEN cb.user_id END) AS horizontal_serious_theme_clicked,
-- COUNT(DISTINCT CASE WHEN ca.user_id is not null  and THEN ca.user_id END) AS gamesettings_tab_changed,
-- COUNT(DISTINCT cc.user_id) AS gamesettings_participant_attempts,
-- COUNT(DISTINCT cd.user_id) AS gamesettings_sns,
-- COUNT(DISTINCT ce.user_id) AS gamesettings_questions_timer,
-- COUNT(DISTINCT cf.user_id) AS gamesettings_name_factory,
-- COUNT(DISTINCT cg.user_id) AS gamesettings_skip_question,
-- COUNT(DISTINCT ch.user_id) AS answer_explanation_toggled,
-- COUNT(DISTINCT ci.user_id) AS gamesettings_redemption_question,
-- COUNT(DISTINCT cj.user_id) AS gamesettings_answers_during_activity,
-- COUNT(DISTINCT ck.user_id) AS gamesettings_focus_mode,
-- COUNT(DISTINCT cl.user_id) AS gamesettings_answers_after_activity,
-- COUNT(DISTINCT cm.user_id) AS gamesettings_shuffle_questions,
-- COUNT(DISTINCT cn.user_id) AS gamesettings_shuffle_answer_options,
-- COUNT(DISTINCT co.user_id) AS gamesettings_student_leaderboard,
-- COUNT(DISTINCT cp.user_id) AS gamesettings_powers_ups,
-- COUNT(DISTINCT cq.user_id) AS gamesettings_play_music,
-- COUNT(DISTINCT cr.user_id) AS gamesettings_show_memes
-- game_type,
-- COUNT(DISTINCT user_id) as users,
-- COUNT(DISTINCT host_id) as hosts,
-- COUNT(DISTINCT CASE WHEN is_classroom_game THEN host_id END) AS mg_hosts,
-- COUNT(DISTINCT game_id) as games,
-- COUNT(DISTINCT CASE WHEN is_classroom_game THEN game_id END) AS mg_games,
-- -- count(distinct case when is_classroom_game AND is_accommodations_used = true then game_id end) as accom_games_2,
-- -- count(distinct case when is_classroom_game AND is_assigned = true then game_id end) as assigned_games,
-- -- count(distinct case when is_classroom_game AND game_type = 'flashcard_async' then game_id end) as `flashcard_async`,
-- -- count(distinct case when is_classroom_game AND game_type = 'test' then game_id end) as `test`,
-- -- count(distinct case when is_classroom_game AND game_type = 'tp' then game_id end) as `tp`,
-- -- count(distinct case when is_classroom_game AND game_type = 'mystic_peak' then game_id end) as `mystic_peak`,
-- -- --count(distinct case when is_classroom_game AND game_type = 'mastery_peak' then game_id end) as `mastery_peak`,
-- -- count(distinct case when is_classroom_game AND game_type = 'team' then game_id end) as `team`,
-- -- count(distinct case when is_classroom_game AND game_type = 'async' then game_id end) as `async`,
-- -- count(distinct case when is_classroom_game AND game_type = 'live' then game_id end) as `live`,
-- -- count(distinct case when is_classroom_game AND game_type = 'challenge' then game_id end) as `challenge`,
-- -- count(distinct case when is_classroom_game AND game_type = 'tp_offline' then game_id end) as `tp_offline`,
-- -- count(distinct case when is_classroom_game AND game_type = 'pres_async' then game_id end) as `pres_async`,
-- -- count(distinct case when is_classroom_game AND game_type = 'pres_tp' then game_id end) as `pres_tp`,
-- COUNT(DISTINCT CASE WHEN is_adaptive IS TRUE AND is_classroom_game THEN game_id END ) AS question_bank,
-- COUNT(DISTINCT CASE WHEN is_ai_answer_explanation IS TRUE AND is_classroom_game THEN game_id END ) AS is_ai_answer_explanation,
-- COUNT(DISTINCT CASE WHEN attempts_permitted <> 0 AND is_classroom_game THEN game_id END ) AS attempts_changed,
-- COUNT(DISTINCT CASE WHEN is_leaderboard_shown IS TRUE AND is_classroom_game THEN game_id END ) AS is_leaderboard_shown,
-- COUNT(DISTINCT CASE WHEN skip_question IS TRUE AND is_classroom_game THEN game_id END ) AS is_skip_ques_enabled,
-- COUNT(DISTINCT CASE WHEN game_type_group = 'Homework' and COALESCE(mastery_mode_goal,mystic_peak_goal) IS NOT NULL AND is_classroom_game THEN game_id
--  WHEN game_type_group = 'Live' and COALESCE(mastery_mode_goal,mystic_peak_goal) IS NOT NULL AND is_classroom_game THEN game_id END ) AS is_mastery_mode ,
-- COUNT(DISTINCT CASE WHEN is_duel_enabled IS TRUE AND is_classroom_game THEN game_id END ) AS is_strike_and_shield,
-- COUNT(DISTINCT CASE WHEN timer != 'off' AND is_classroom_game THEN game_id END ) AS is_timer_on,
-- COUNT(DISTINCT CASE WHEN is_redemption IS TRUE AND is_classroom_game THEN game_id END ) AS is_redemption_qus_enabled,
-- COUNT(DISTINCT CASE WHEN is_powerups_enabled IS TRUE AND is_classroom_game THEN game_id END ) AS is_powerups_enabled,
-- COUNT(DISTINCT CASE WHEN is_meme_shown IS TRUE AND is_classroom_game THEN game_id END ) AS is_meme_shown,
-- COUNT(DISTINCT CASE WHEN is_quiz_jumbled IS TRUE AND is_classroom_game THEN game_id END ) AS shuffle_qus_enabled,
-- COUNT(DISTINCT CASE WHEN is_student_live_reaction_enabled IS TRUE AND is_classroom_game THEN game_id END ) AS student_live_reaction,
-- COUNT(DISTINCT CASE WHEN is_answer_shown <> 'always' AND is_classroom_game THEN game_id END ) AS is_answer_not_shown,
-- COUNT(DISTINCT CASE WHEN is_focus_mode IS TRUE AND is_classroom_game THEN game_id END ) AS is_focus_mode,
-- COUNT(DISTINCT CASE WHEN is_review_and_submit IS TRUE AND is_classroom_game THEN game_id END ) AS is_review_and_submit,
-- COUNT(DISTINCT CASE WHEN is_nickname_generated IS TRUE AND is_classroom_game THEN game_id END ) AS is_nickname_generated,
-- COUNT(DISTINCT CASE WHEN are_answers_jumbled IS TRUE AND is_classroom_game THEN game_id END ) AS are_answers_jumbled,
-- COUNT(DISTINCT CASE WHEN is_no_frills IS TRUE AND is_classroom_game THEN game_id END ) AS serious_games,
-- count(distinct case when is_schedule_later = true and is_classroom_game then game_id end) as is_schedule_later,
-- count(distinct case when is_quiz_without_correct_answers = true and is_classroom_game then game_id end) as is_quiz_without_correct_answers,
FROM new_ff A

-- AND B.is_classroom_game IS TRUE
-- AND B.is_focus_mode IS TRUE
LEFT JOIN track.game_settings_preview_button_clicked AS ca 
ON A.user_id = ca.user_id AND DATE(A.dt) = DATE(ca.created_at)
LEFT JOIN clean.game B
ON ca.user_id = B.host_id
AND DATE(B.created_at) >= '2025-09-01'
AND DATE(ca.created_at) = DATE(B.created_at)
AND game_type in ('tp')
AND quiz_type in ('quiz')
GROUP BY 1
ORDER BY 1
-- LEFT JOIN track.game_setting_anti_cheating_clicked AS cb ON B.host_id = cb.user_id AND DATE(B.created_at) = DATE(cb.created_at)
-- WHERE A.variation_id = 'ENABLED'
-- LEFT JOIN track.gamesettings_participant_attempts AS cc ON B.host_id = cc.user_id AND DATE(B.created_at) = DATE(cc.created_at)
-- LEFT JOIN track.gamesettings_sns AS cd ON B.host_id = cd.user_id AND DATE(B.created_at) = DATE(cd.created_at)
-- LEFT JOIN track.gamesettings_questions_timer AS ce ON B.host_id = ce.user_id AND DATE(B.created_at) = DATE(ce.created_at)
-- LEFT JOIN track.gamesettings_name_factory AS cf ON B.host_id = cf.user_id AND DATE(B.created_at) = DATE(cf.created_at)
-- LEFT JOIN track.gamesettings_skip_question AS cg ON B.host_id = cg.user_id AND DATE(B.created_at) = DATE(cg.created_at)
-- LEFT JOIN track.answer_explanation_toggled AS ch ON B.host_id = ch.user_id AND DATE(B.created_at) = DATE(ch.created_at)
-- LEFT JOIN track.gamesettings_redemption_question AS ci ON B.host_id = ci.user_id AND DATE(B.created_at) = DATE(ci.created_at)
-- LEFT JOIN track.gamesettings_answers_during_activity AS cj ON B.host_id = cj.user_id AND DATE(B.created_at) = DATE(cj.created_at)
-- LEFT JOIN track.gamesettings_focus_mode AS ck ON B.host_id = ck.user_id AND DATE(B.created_at) = DATE(ck.created_at)
-- LEFT JOIN track.gamesettings_answers_after_activity AS cl ON B.host_id = cl.user_id AND DATE(B.created_at) = DATE(cl.created_at)
-- LEFT JOIN track.gamesettings_shuffle_questions AS cm ON B.host_id = cm.user_id AND DATE(B.created_at) = DATE(cm.created_at)
-- LEFT JOIN track.gamesettings_shuffle_answer_options AS cn ON B.host_id = cn.user_id AND DATE(B.created_at) = DATE(cn.created_at)
-- LEFT JOIN track.gamesettings_student_leaderboard AS co ON B.host_id = co.user_id AND DATE(B.created_at) = DATE(co.created_at)
-- LEFT JOIN track.gamesettings_powers_ups AS cp ON B.host_id = cp.user_id AND DATE(B.created_at) = DATE(cp.created_at)
-- LEFT JOIN track.gamesettings_play_music AS cq ON B.host_id = cq.user_id AND DATE(B.created_at) = DATE(cq.created_at)
-- LEFT JOIN track.gamesettings_show_memes AS cr ON B.host_id = cr.user_id AND DATE(B.created_at) = DATE(cr.created_at)
-- )
-- group by 1,2,3