-- Analysis looking at customer sleep and activity

-- count of users in the dataset
SELECT COUNT (DISTINCT id) AS user_id
FROM compact-medium-464517-i0.Fitbit_data.Sleeplog

-- how much sleep is each user getting every night, ordered by id, night 
SELECT 
Id AS user_id, 
`date` AS night, 
COUNT (`time`) AS minutes_asleep,  
ROUND (COUNT (`time`)/60 ,1) AS hours_asleep 
FROM compact-medium-464517-i0.Fitbit_data.Sleeplog
GROUP BY Id, `date`
ORDER BY user_id, night

-- average amount of sleep for all the users for the month
SELECT 
ROUND (AVG (hours_asleep), 1) AS avg_hours_slept
FROM 
(SELECT 
Id AS users, 
`date` AS night, 
COUNT (`time`) AS minutes_asleep,  
COUNT (`time`)/60 AS hours_asleep 
FROM compact-medium-464517-i0.Fitbit_data.Sleeplog
GROUP BY Id, `date`) AS sleep_table

-- average amount of sleep broken down overall
SELECT 
ROUND (AVG (hours_asleep), 1) AS avg_hours_slept
FROM 
(SELECT 
Id AS users, 
`date` AS night, 
COUNT (`time`) AS minutes_asleep,  
COUNT (`time`)/60 AS hours_asleep 
FROM compact-medium-464517-i0.Fitbit_data.Sleeplog
GROUP BY Id, `date`) AS sleep_table

-- average sleep per user + what activity level they fall in overall
WITH avg_hours_slept_per_user AS 
(SELECT user_id, 
ROUND (AVG (hours_asleep), 1) AS avg_hours_slept
FROM (SELECT Id AS user_id, 
      `date` AS night, 
      COUNT (`time`) AS minutes_asleep,  
      COUNT (`time`)/60 AS hours_asleep 
      FROM compact-medium-464517-i0.Fitbit_data.Sleeplog
      GROUP BY Id, `date`) AS sleep_table
GROUP BY user_id),
activity AS
(SELECT Id AS user_id, 
CASE WHEN AVG(VeryActiveMinutes) >= 30 THEN 'Very Active'
     WHEN AVG(VeryActiveMinutes) >= 15 THEN 'Moderately Active'
     ELSE 'Less Active'
END AS activity_level, 
ROUND (AVG(veryactiveminutes),1) AS avg_veryactive_minutes, 
ROUND (AVG(fairlyactiveminutes),1) AS avg_fairlyactive_minutes,
ROUND (AVG(lightlyactiveminutes),1) AS avg_lightlyactive_minutes,
ROUND (AVG(sedentaryminutes),1) AS avg_sedentary_minutes
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity 
GROUP BY user_id) 

SELECT t1.user_id, t1.avg_hours_slept, t2.activity_level, t2.avg_veryactive_minutes 
FROM avg_hours_slept_per_user AS t1
JOIN activity AS t2 
  ON t1.user_id = t2.user_id

-- sleep for users on the weekend and the weekdays 
WITH weekend_weekday_sleep_distribution AS (
  SELECT 
    Id AS user_id,
    day_type,
    ROUND(AVG(hours_asleep), 1) AS avg_hours_slept
  FROM (
    SELECT 
      Id,  
      `date` AS night, 
      COUNT(`time`) / 60 AS hours_asleep,
      CASE 
        WHEN FORMAT_DATE('%A', DATE(date)) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
      END AS day_type
    FROM compact-medium-464517-i0.Fitbit_data.Sleeplog
    GROUP BY Id, night, day_type
  )
  GROUP BY user_id, day_type
), 

activity AS (
  SELECT 
    Id AS user_id,
    CASE 
      WHEN AVG(VeryActiveMinutes) >= 30 THEN 'Very Active'
      WHEN AVG(VeryActiveMinutes) >= 15 THEN 'Moderately Active'
      ELSE 'Less Active'
    END AS activity_level, 
    CASE 
      WHEN FORMAT_DATE('%A', DATE(ActivityDate)) IN ('Saturday', 'Sunday') THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_type, 
    ROUND(AVG(VeryActiveMinutes), 1) AS avg_veryactive_minutes, 
    ROUND(AVG(FairlyActiveMinutes), 1) AS avg_fairlyactive_minutes,
    ROUND(AVG(LightlyActiveMinutes), 1) AS avg_lightlyactive_minutes,
    ROUND(AVG(SedentaryMinutes), 1) AS avg_sedentary_minutes
  FROM compact-medium-464517-i0.Fitbit_data.DailyActivity 
  GROUP BY user_id, day_type
)

SELECT
  wsd.user_id, 
  wsd.day_type, 
  wsd.avg_hours_slept,
  a.activity_level, 
  a.avg_veryactive_minutes
FROM weekend_weekday_sleep_distribution wsd
JOIN activity a
  ON wsd.user_id = a.user_id 
  AND wsd.day_type = a.day_type;
