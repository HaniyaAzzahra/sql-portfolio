/*
Author : Haniya Azzahra 01-June-2026
question link : https://datalemur.com/questions/sql-histogram-tweets
*/

WITH tweet_bucket_per_user as (

  SELECT 
    user_id
    , count(tweet_id) tweet_bucket
  FROM tweets
  WHERE 
    extract(year from tweet_date) = 2022
  GROUP BY  
    user_id
  
)

 SELECT
    tweet_bucket
    , count(user_id) users_num
  FROM  
    tweet_bucket_per_user 
  GROUP BY 
    tweet_bucket
    