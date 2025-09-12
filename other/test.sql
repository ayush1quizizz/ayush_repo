WITH new_ff as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-10' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'mode-selection'
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)
,glo_cntrl as (
select distinct ff.user_id,date(ff.experiment_date) as dt, variation_id,experiment_id
from transformed.user_feature_flag_map_most_frequent_in_a_day ff
inner join clean.user u
on ff.user_id = u.user_id
where date(ff.experiment_date) >= '2025-09-10' 
AND date(ff.experiment_date) < current_date()
--AND (activation_at IS NULL OR DATE(activation_at) >= experiment_date)
--AND DATE(u.created_at) >= '2025-09-01'
and ff.experiment_id = 'delivery-global-control'
--and variation_id = 'ASYNC_LIVE_DASHBOARD'
and u.email not like '%quizizz.com'
and u.email not like '%wayground.com'
and u.country = 'US'
and u.occupation = 'teacher'
)

select a.dt,
       COUNT(DISTINCT CASE WHEN a.glob_variation_id = 'CONTROL' THEN a.glob_user_id END) as control_users,
       COUNT(DISTINCT CASE WHEN a.glob_variation_id = 'CONTROL' AND a.variation_id IN ('ENABLED','DISABLED') THEN a.glob_user_id END) as control_users__horizontal_setting,
from (
select distinct a.dt,a.user_id as glob_user_id,a.experiment_id as glob_exp_id,a.variation_id as glob_variation_id,b.user_id,b.experiment_id,b.variation_id
from glo_cntrl a 
left join new_ff b 
on a.dt = b.dt
and a.user_id =b.user_id
) a
group by 1
order by 1









