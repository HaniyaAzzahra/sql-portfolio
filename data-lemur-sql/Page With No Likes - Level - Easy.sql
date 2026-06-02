/*
Author : Haniya Azzahra 01-June-2026
question link : https://datalemur.com/questions/sql-page-with-no-likes
*/


select 
	pages.page_id
from 
	pages
left join 
	page_likes on page_likes.page_id = pages.page_id
group by 
	pages.page_id
having count(page_likes.page_id) = 0
order by 
pages.page_id