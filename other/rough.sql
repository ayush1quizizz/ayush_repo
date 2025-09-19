select distinct game_id,
       created_at,
       expiry_at,
       soft_expiry_at,
       late_submission_expiry_at,
from clean.game 
where date(created_at )>= '2025-09-01'
and is_classroom_game = true
and host_country = 'US'
and host_occupation = 'teacher'
and game_type = 'async'
and soft_expiry_at is null
