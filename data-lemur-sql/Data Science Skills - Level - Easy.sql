/*
Author : Haniya Azzahra 01-June-2026
question link : https://datalemur.com/questions/matching-skills
*/

SELECT 
  candidate_id
FROM 
  candidates
WHERE 
  skill in ('Python','Tableau','PostgreSQL')
GROUP BY 
  candidate_id
HAVING count(skill) = 3