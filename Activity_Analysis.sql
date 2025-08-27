-- User Activity Analysis 


-- count of users in the dataset
SELECT COUNT(DISTINCT id) AS user_id_count
FROM `compact-medium-464517-i0.Fitbit_data.DailyActivity`

-- users categorized by activity level
SELECT  Id AS user_id, 
CASE WHEN AVG(VeryActiveMinutes) >= 30 THEN 'Very Active'
     WHEN AVG(VeryActiveMinutes) >= 15 THEN 'Moderately Active'
     ELSE 'Less Active'
END AS activity_level, 
ROUND (AVG(veryactiveminutes),1) AS veryactive_avg, 
ROUND (AVG(fairlyactiveminutes),1) AS fairlyactive_avg,
ROUND (AVG(lightlyactiveminutes),1) AS lightlyactive_avg,
ROUND (AVG(sedentaryminutes),1) AS sedentary_avg
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity
GROUP BY id 

-- users activity levels on the weekend vs the weekdays 
SELECT  Id AS user_id,
CASE 
  WHEN FORMAT_DATE('%A', DATE(ActivityDate)) IN ('Saturday', 'Sunday') THEN 'Weekend'
  ELSE 'Weekday'
END AS day_type,
CASE WHEN AVG(VeryActiveMinutes) >= 30 THEN 'Very Active'
     WHEN AVG(VeryActiveMinutes) >= 15 THEN 'Moderately Active'
     ELSE 'Less Active'
END AS activity_level, 
ROUND (AVG(veryactiveminutes),1) AS veryactive_avg, 
ROUND (AVG(fairlyactiveminutes),1) AS fairlyactive_avg,
ROUND (AVG(lightlyactiveminutes),1) AS lightlyactive_avg,
ROUND (AVG(sedentaryminutes),1) AS sedentary_avg
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity
GROUP BY id, day_type
ORDER BY id

-- comparing the very active participants to the other 2 category of participants (moderately and less active) 
SELECT  id AS user_id, 
CASE WHEN AVG(VeryActiveMinutes) >= 30 THEN 'Very Active'
     WHEN AVG(VeryActiveMinutes) >= 15 THEN 'Moderately Active'
     ELSE 'Less Active'
END AS activity_level, 
ROUND (AVG(veryactiveminutes),1) AS veryactive_avg, 
ROUND (AVG(fairlyactiveminutes),1) AS fairlyactive_avg,
ROUND (AVG(lightlyactiveminutes),1) AS lightlyactive_avg,
ROUND (AVG(sedentaryminutes),1) AS sedentary_avg, 
ROUND (AVG (TotalSteps), 1) AS monthlysteps_avg,
ROUND (AVG (Calories), 1) AS caloriesburned_, 
ROUND (AVG (TotalDistance), 1) AS monthlydistance_avg
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity
GROUP BY id

