-- Analysis of user behavior patterns with the fitbit ecosystem 

-- count of users in the dataset
SELECT COUNT (DISTINCT id) AS users 
FROM compact-medium-464517-i0.Fitbit_data.Weightlog
  
--overall average activity levels of the users who logged weight data
SELECT activity_table.Id AS users,
CASE WHEN AVG(activity_table.VeryActiveMinutes) >= 30 THEN 'very active'
    WHEN AVG(activity_table.VeryActiveMinutes) >= 15 THEN  'moderately active'
    ELSE 'less active'
END AS user_activity_level, 
ROUND (AVG (VeryActiveminutes)) AS veryactive, 
ROUND (AVG(FairlyActiveMinutes)) AS fairlyactive , 
ROUND (AVG (LightlyActiveMinutes)) AS lightlyactive, 
ROUND (AVG(SedentaryMinutes)) AS sedentaryminutes
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity AS activity_table
JOIN compact-medium-464517-i0.Fitbit_data.Weightlog AS weight_table
ON activity_table.id = weight_table.id
GROUP BY activity_table.id
  
-- average activity level for users on only the days they logged weight 
SELECT 
weight.Id AS user, 
CASE WHEN AVG(activity.VeryActiveMinutes) >= 30 THEN 'very active'
    WHEN AVG(activity.VeryActiveMinutes) >= 15 THEN  'moderately active'
    ELSE 'less active'
END AS user_activity_level,
ROUND(AVG(activity.VeryActiveMinutes),1) AS veryactive, 
ROUND(AVG(activity.FairlyActiveMinutes),1) AS fairlyactive,
ROUND(AVG (activity.LightlyActiveMinutes),1) AS lightlyactive,
ROUND (AVG (activity.SedentaryMinutes),1) AS sedentaryactive
FROM compact-medium-464517-i0.Fitbit_data.Weightlog AS weight
JOIN compact-medium-464517-i0.Fitbit_data.DailyActivity AS activity 
ON weight.Id= activity.Id and weight.date = activity.ActivityDate
GROUP BY weight.Id

-- average activity level for users on every day they did not log weight
SELECT 
activity.id AS user,
CASE WHEN AVG(activity.VeryActiveMinutes) >= 30 THEN 'very active'
    WHEN AVG(activity.VeryActiveMinutes) >= 15 THEN  'moderately active'
    ELSE 'less active'
END AS user_activity_level,
ROUND(AVG(activity.VeryActiveMinutes),1) AS veryactive, 
ROUND(AVG(activity.FairlyActiveMinutes),1) AS fairlyactive,
ROUND(AVG (activity.LightlyActiveMinutes),1) AS lightlyactive,
ROUND (AVG (activity.SedentaryMinutes),1) AS sedentaryactive
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity AS activity
WHERE activity.id IN (
    SELECT DISTINCT id FROM compact-medium-464517-i0.Fitbit_data.Weightlog
)
AND NOT EXISTS (
    SELECT *
    FROM compact-medium-464517-i0.Fitbit_data.Weightlog AS weight
    WHERE weight.id = activity.id
      AND weight.date = activity.ActivityDate
)
GROUP BY activity.id
--- how many users did not log weight
SELECT  COUNT (DISTINCT Id) AS users, 
FROM compact-medium-464517-i0.Fitbit_data.DailyActivity
WHERE id NOT IN 
     (SELECT id
FROM compact-medium-464517-i0.Fitbit_data.Weightlog)

-- activity levels for users who did not log weight (activity only) 
SELECT  Id AS users, 
CASE WHEN AVG(VeryActiveMinutes) >= 30 THEN 'Very Active'
     WHEN AVG(VeryActiveMinutes) >= 15 THEN 'Moderately Active'
