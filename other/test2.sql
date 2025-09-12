WITH paid_org_tab AS (
SELECT
A.paid_org_id,
A.subscription_start_at AS latest_sub_start_at, -- latest sub start
A.subscription_end_at AS latest_sub_end_at, -- latest sub end
A.country,
A.deal_org_type,
B.start_at AS all_sub_start_at,
B.end_at AS all_sub_end_at,
B.plan_id,
FROM
(SELECT
paid_org_id,
subscription_start_at, -- latest sub start
subscription_end_at, -- latest sub end
country,
deal_org_type,
FROM
clean.paid_org
-- use product group for filtering
) A
JOIN
(SELECT
*
FROM
`clean.customer_subscription`
QUALIFY ROW_NUMBER() OVER (PARTITION BY paid_org_id, start_date ORDER BY status ASC) = 1
) B
ON A.paid_org_id = B.paid_org_id
AND plan_id NOT IN ('snd_trial','pilot_plan','snd_pilot')
AND A.country = 'US'
--AND CURRENT_DATE() < DATE(A.subscription_end_at) -- to get only active subscriptions currently
AND CURRENT_DATE() BETWEEN B.start_date AND B.end_date
)
,base AS (
SELECT
       a.paid_organization_id,
       a.user_id,
       COALESCE(test_results,'NA') AS test_results
FROM  track.wayground_compatibility_checker a
-- inner join clean.user u
-- ON a.user_id = u.user_id
--WHERE paid_organization_id IS NULL
-- left join clean.user u
-- ON a.user_id = u.user_id
)
,base2 AS (
SELECT DISTINCT
       u.org_id,
       u.org_name,
       a.*
FROM (
SELECT DISTINCT
       paid_organization_id,
       user_id,
       SUM(CASE WHEN test_results = 'NA' THEN 1 ELSE 0 END) AS no_error,
       SUM(CASE WHEN test_results LIKE '%play/check%' THEN 1 ELSE 0 END) AS play_check_error,
       SUM(CASE WHEN test_results NOT LIKE '%play/check%' AND test_results != 'NA' THEN 1 ELSE 0 END) AS other_error
FROM base
GROUP BY 1,2
) a
INNER JOIN clean.user u
ON a.user_id = u.user_id
WHERE u.occupation = 'teacher'
AND u.email NOT LIKE '%quizizz.com'
)
,final_base AS (
SELECT org_id,
       org_name,
       paid_organization_id,
       COUNT(DISTINCT user_id) AS total_users,
       COUNT(DISTINCT CASE WHEN no_error > 0 AND play_check_error = 0 AND other_error = 0  THEN user_id END) AS no_error_users,
       --COUNT(DISTINCT CASE WHEN play_check_error = 0 AND other_error = 0 THEN user_id END) AS no_error_users,
       COUNT(DISTINCT CASE WHEN play_check_error != 0 THEN user_id END) AS play_check_error_users,
       COUNT(DISTINCT CASE WHEN other_error != 0 THEN user_id END) AS other_error_users,
FROM base2
GROUP BY 1,2,3
)
,stud_base AS (
SELECT DISTINCT
       a.paid_organization_id,
       a.user_id,
       a.session_id,
       u.host_id,
       COALESCE(test_results,'NA') AS test_results
FROM  track.wayground_compatibility_checker a
INNER JOIN clean.game_attempt u
ON a.session_id = u.session_id
WHERE DATE(u.game_created_at) >= '2025-01-01'
)
,stud_base2 AS (
SELECT DISTINCT
       u.org_id,
       u.org_name,
       a.*
FROM (
SELECT
       paid_organization_id,
       host_id,
       session_id,
       SUM(CASE WHEN test_results = 'NA' THEN 1 ELSE 0 END) AS no_error,
       SUM(CASE WHEN test_results LIKE '%play/check%' THEN 1 ELSE 0 END) AS play_check_error,
       SUM(CASE WHEN test_results NOT LIKE '%play/check%' AND test_results != 'NA' THEN 1 ELSE 0 END) AS other_error
FROM stud_base
GROUP BY 1,2,3
) a
INNER JOIN clean.user u
ON a.host_id = u.user_id
)
,stud_final_base AS (
SELECT org_id,
       org_name,
       paid_organization_id,
       COUNT(DISTINCT session_id) AS total_players,
       COUNT(DISTINCT CASE WHEN no_error > 0 AND play_check_error = 0 AND other_error = 0  THEN session_id END) AS no_error_players,
       --COUNT(DISTINCT CASE WHEN play_check_error = 0 AND other_error = 0 THEN user_id END) AS no_error_users,
       COUNT(DISTINCT CASE WHEN play_check_error != 0 THEN session_id END) AS play_check_error_players,
       COUNT(DISTINCT CASE WHEN other_error != 0 THEN session_id END) AS other_error_players,
FROM stud_base2
GROUP BY 1,2,3
)
,req1 AS (
SELECT DISTINCT
       a.org_id,
       a.org_name,
       a.paid_organization_id,
       CASE WHEN CURRENT_DATE() < DATE(b.latest_sub_end_at) THEN 'Active' ELSE 'Closed' END AS status,
       b.latest_sub_start_at AS subscription_start_at,
       a.total_users,
       a.no_error_users,
       a.play_check_error_users,
       a.other_error_users
FROM final_base a
LEFT JOIN paid_org_tab b
ON a.paid_organization_id = b.paid_org_id
)
,req2 AS (
SELECT DISTINCT
       a.org_id,
       a.org_name,
       a.paid_organization_id,
       a.total_players,
       a.no_error_players,
       a.play_check_error_players,
       a.other_error_players
FROM stud_final_base a
)
SELECT DISTINCT
       a.*,
       b.total_players,
       b.no_error_players
FROM req1 a
LEFT JOIN req2 b
ON COALESCE(a.org_id,'NA') = COALESCE(b.org_id,'NA')
AND COALESCE(a.org_name,'NA') = COALESCE(b.org_name,'NA')
AND COALESCE(a.paid_organization_id,'NA') = COALESCE(b.paid_organization_id,'NA')
ORDER BY 6 DESC