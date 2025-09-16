SELECT 
dt,
game_type, 
SUM(player_cnt) AS player_cnt, 
SUM(rating) AS rating
FROM(
      SELECT
      g.game_type, 
      g.game_id,
      date(g.created_at) AS dt,
      COUNT(DISTINCT a.session_id) AS player_cnt,
      SUM(a.rating) AS rating
      FROM(
          SELECT 
            feedback_id AS id,
            --max(date(createdAt)) as created_date,
            session_id,
            quiz_id,
            game_id,
            game_type,
            rating/2 AS rating
            FROM `quizizz-org.clean.NPS` 
            WHERE date(created_at) BETWEEN CURRENT_DATE()-400 and CURRENT_DATE()
            ) a
      INNER JOIN `quizizz-org.clean.game` g
      ON a.game_id= g.game_id 
      WHERE host_country='US' and host_occupation='teacher'
      AND g.game_type IN ('live','mystic_peak','async')
      AND players>1 and responses>0
      AND DATE(created_at) BETWEEN CURRENT_DATE()-365 and CURRENT_DATE()
      AND rating is not null
      GROUP BY 1,2,3
      )
GROUP BY 1,2