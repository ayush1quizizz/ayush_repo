select date(game_created_at) as dt, 
       game_id,
       session_id,
       player_id
from clean.game_attempt
where game_id = '68b72eb36f17ad097e2068f3'
--focusMode
--tab_switch_alert_dismiss_all_alerts
--tab_switch_alert_remove