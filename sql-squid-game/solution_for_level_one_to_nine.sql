/*
Author : Haniya Azzahra / 31-May-2026
*/


/* 
LEVEL 1 
Question : The organizers want to identify vulnerable living players 
who might be easily manipulated for the next game. 
Find all players who are alive, 
in severe debt (debt > 400,000,000 won), 
and are either elderly (age > 65) 
OR have a vice of Gambling with no family connections.
*/

	select 
		*
	from 
		player
	where 
		status = 'alive'
	and debt > 400000000
	and (age > 65 or (vice = 'Gambling' and has_close_family = false ))


/*
Level 2
The organizers need to calculate how many food portions to withhold to create the right amount of tension. 
In a table, calculate how many rations would feed 90% of the remaining(alive) non-insider players (rounded down), 
and in another column, indicate if the current rations supply is sufficient. 
(True or False)
*/

	select 
	      ratio_needed
		, case when rations.amount >=  ratio_needed then true end is_ratio_sufficient
	from (
		select 
			floor(count(id) * 0.9) ratio_needed
		from 
			player
		where 
			status = 'alive'
		and IsInsider = false
	     ) ratio_needed
	cross join 
		rations




/*
Level 3
Analyze the average completion times 
for each shape in the honeycomb game during the hottest and coldest months, 
using data from the past 20 years only. 
Order the results by average completion time.
*/


                
    with 
	get_lowest_and_coldest_month as (
	
	select 
		month
		, avg_temperature
	from (
		select 
			month
			, avg_temperature
			, row_number() over (order by avg_temperature ASC) as min_rank
			, row_number() over (order by avg_temperature DESC) as max_rank
		from 
			monthly_temperatures
	)cte 
	where 
		min_rank = 1
	or  max_rank = 1
	
	
	
	)
	
	select 
		shape
		, get_lowest_and_coldest_month.month 
		, avg(average_completion_time) avg_completion_time
	from 
		honeycomb_game
	join 
		get_lowest_and_coldest_month on get_lowest_and_coldest_month.month  = DATE_PART('month', honeycomb_game.date) 
	where 
		date >= CURRENT_DATE - INTERVAL '20 years'
	group by 
		shape   
		, get_lowest_and_coldest_month.month
		

/*
Level 4
The Front Man needs to analyze and rank the teams before the Tug of War game begins. 
For each team that has exactly 10 players, calculate their average player age. 
Additionally, categorize the teams based on their average player age into three age groups:

'Fit': Average age < 40
'Grizzled': Average age between 40 and 50 (inclusive)
'Elderly': Average age > 50

Show the team_id, average age, age group, and 
rank the teams based on their average player age (highest average age = rank 1).
*/

     select 
			team_id
			, avg(age) "average age"
			, case when avg(age) < 40 then 'Fit'
				   when avg(age) between 40 and 50 then 'Grizzled'
				   when avg(age) > 50 then 'Elderly'
				   end "age group"
		    , RANK() OVER (ORDER BY AVG(age) DESC) AS age_rank
		from 
			player
		where 
			status = 'alive'
		and team_id is not null
		group by 
			team_id
		having count(id) = 10
		order by age_rank
		
/*
Level 5
For the Marbles game, the Front Man needs you to discover who Player 456's closest companion is. 
First, find the player who has interacted with Player 456 the most frequently in daily activities. 
Then, confirm this player is still alive and return a row with both players' first names, 
and the number of interactions they've had.
*/

with the_highest_player_interaction as (
	select
	     
		CASE
            WHEN player1_id = 456 THEN player2_id
            ELSE player1_id
        END AS other_player_id
        , count(id) total_interaction	
	from 
		daily_interactions
	where 
		player1_id = 456 or player2_id = 456
	group by 
		CASE
            WHEN player1_id = 456 THEN player2_id
            ELSE player1_id
        END 
     order by count(id) desc
     limit 1

)

	select 
		p1.first_name as player1_name
		, p2.first_name as player2_name
		, total_interaction	
	from 
		the_highest_player_interaction
	join player p1 on p1.id = 456
	join player p2 on p2.id = other_player_id

	

	
/* level 6
	The guards are investigating equipment durability across different game types, 
	as some equipment has been breaking prematurely. 
	Determine the game type with the highest number of equipment failures 
	and identify the supplier responsible for the most failures within that game type.
	Finally, calculate the average lifespan until first failure,
    in whole years (using 365.2425 days per year), 
    of all failed equipment supplied by this supplier for the most faulty game type.
*/
	
	-- this one i copy from data lemur XD 
	
WITH MostFailedGameType AS (
    SELECT e.game_type
    FROM equipment e
    JOIN failure_incidents fi ON e.id = fi.failed_equipment_id
    GROUP BY e.game_type
    ORDER BY COUNT(*) DESC
    LIMIT 1
),
WorstSupplier AS (
    SELECT e.supplier_id
    FROM equipment e
    JOIN failure_incidents fi ON e.id = fi.failed_equipment_id
    WHERE e.game_type = (SELECT game_type FROM MostFailedGameType)
    GROUP BY e.supplier_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
),
FirstFailures AS (
    SELECT e.id, MIN(fi.failure_date) as first_failure_date
    FROM equipment e
    JOIN failure_incidents fi ON e.id = fi.failed_equipment_id
    GROUP BY e.id
)
SELECT 
    FLOOR(AVG((ff.first_failure_date - e.installation_date) / 365.2425)) AS avg_lifespan_years
FROM equipment e
JOIN FirstFailures ff ON e.id = ff.id
WHERE e.supplier_id = (SELECT supplier_id FROM WorstSupplier);




/* level 7
*/
	


	select 
		guard.id "Guard Number"
		, guard.code_name "Code Name"
		, guard.status "Status"
		, room.last_check_time "Last Seen in Room"
		, camera.movement_detected_time "Spotted Outside Room Time"
		, camera.location "Spotted Outside Room Location"
		, camera.movement_detected_time - room.last_check_time "Time between room and outside"
		, (SELECT MAX(movement_detected_time) - MIN(movement_detected_time)
   			FROM camera 
   				 where guard_spotted_id IS NOT NULL) AS "Time Range"
	from 
		guard
	left join 
		camera on camera.guard_spotted_id = guard.id
	join 
		room on room.id = guard.assigned_room_id
	where 
		room.isVacant = true 
	and camera.movement_detected = true
		

/* level 8
*/
	with highest_game_hesitation as (
	select 
		game_id
        , glass_bridge.date
		, avg(last_moved_time_seconds) avg_hesitation
	from 
		player
	join 
		glass_bridge on glass_bridge.id = player.game_id  
	where lower(death_description) like '%pushed%'
  group by game_id, glass_bridge.date
	order by avg(last_moved_time_seconds)  desc 
	limit 1
	)
	
select 
		player.id AS player_id
        , player.first_name
		, player.last_name
		, last_moved_time_seconds AS hesitation_time
		
	from 
		player
	join highest_game_hesitation  on highest_game_hesitation.game_id = 	player.game_id 
	where lower(death_description) like '%pushed%'
		order by last_moved_time_seconds desc 
		limit 1
		
/* level 9
*/
	WITH disappearance_window AS (
    SELECT date, start_time, end_time
    FROM game_schedule
    WHERE type = 'Squid Game'
    ORDER BY date DESC
    LIMIT 1
),
guards_away AS (
    SELECT g.id AS guard_id, g.assigned_post, g.shift_start, g.shift_end, dal.door_location, dal.access_time
    FROM guard g
    JOIN disappearance_window dw
    ON g.shift_start < dw.end_time AND g.shift_end > dw.start_time
    LEFT JOIN daily_door_access_logs dal
    ON dal.guard_id = g.id
    AND dal.access_time BETWEEN g.shift_start AND g.shift_end
    WHERE g.assigned_post != dal.door_location
),
suspicious_access AS (
    SELECT
        g.id AS potential_associate_id,
        dal.access_time AS time_accessed
    FROM daily_door_access_logs dal
    JOIN guard g ON g.id = dal.guard_id
    WHERE dal.door_location = 'Upper Management'
    AND dal.access_time BETWEEN '11:00:00'::time AND '12:00:00'::time
    AND g.id != 31
)
SELECT * FROM suspicious_access;	
		