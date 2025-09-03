
with base as (
select distinct 
       g.host_id,
      -- ff.user_id,
       g.game_id,
       g.created_at,
      -- date(g.created_at) as dt,
      -- count(distinct g.game_id) as games,
      -- count(distinct case when ff.user_id is not null then game_id end) as enabled_games,
      -- count(distinct g.host_id) as hosts,
      -- count(distinct case when ff.user_id is not null then host_id end) as enabled_hosts
from clean.game g
inner join transformed.user_feature_flag_map_most_frequent_in_a_day ff 
on g.host_id = ff.user_id 
and date(experiment_date) >= '2025-07-29'
and ff.experiment_id = 'pulse-visiblity'
and variation_id = 'ENABLED'
where date(g.created_at) >= '2025-07-29'
and g.host_country = 'US'
and g.host_occupation = 'teacher'
and g.is_classroom_game
and quiz_type = 'presentation'
--and game_type IN ('tp','pres_tp')
-- group by 1
-- order by 1

)


select date(b.created_at) as dt,
       count(distinct b.game_id) as total_games,
       count(distinct op.game_id) as open_classroom,
       count(distinct lo.game_id) as locked_games,
       count(distinct ul.game_id) as unlocked_games,
      count(distinct vc.game_id) as view_correct,
       count(distinct rc.game_id) as response_checked,
       count(distinct re.game_id) as response_expand,
       count(distinct fc.game_id) as filter_changed,
       count(distinct sc.game_id) as next_screen,
       count(distinct lc.game_id) as hand_lower,
       count(distinct sb.game_id) as switch_sub_tab,
       count(distinct acc.game_id) as accuracy_sorted,
       count(distinct sp.game_id) as spotlight_clicked,
       count(distinct vt.game_id) as visiblity_toggled,
from base b 
left join track.lessons_2_classroom_pulse_button_clicked op
on (b.game_id =  REGEXP_EXTRACT(op.url, r'\/lesson\/([^\/?]+)')  OR b.game_id = op.game_id)
left join track.lessons_2_cp_page_load_locked lo
on (b.game_id = REGEXP_EXTRACT(lo.url, r'\/lesson\/([^\/]+)\/pulseV2') OR b.game_id = lo.game_id)
left join track.lessons_2_cp_page_load_unlocked ul
on (b.game_id = REGEXP_EXTRACT(ul.url, r'\/lesson\/([^\/]+)\/pulseV2') OR b.game_id = ul.game_id)
left join track.activity_cp_view_correct_answer_clicked vc
on b.game_id =  vc.game_id
left join track.activity_cp_student_response_checked rc
on b.game_id = rc.game_id
left join track.activity_cp_response_expanded re
on b.game_id = re.game_id
left join track.acitivity_cp_question_filter_changed fc
on b.game_id = fc.game_id
left join track.activity_cp_next_screen_clicked sc
on b.game_id = sc.game_id
left join track.activity_cp_hand_raise_lower_click lc
on b.game_id = lc.game_id
left join track.activity_cp_switch_sub_tab sb
on b.game_id = sb.game_id
left join track.activity_cp_accuracy_sorted acc
on b.game_id = acc.game_id
left join track.activity_cp_response_tile_spotlight_clicked sp
on b.game_id = sp.game_id
left join track.activity_cp_response_tile_visibility_toggled vt
on b.game_id = vt.game_id
group by 1
order by 1
