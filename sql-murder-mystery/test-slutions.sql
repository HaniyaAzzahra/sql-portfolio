with 
    master_person as ( 
	
	select 
		person.*
		, drivers_license.age
		, drivers_license.height
		, drivers_license.eye_color
		, drivers_license.hair_color
		, drivers_license.gender
		, drivers_license.plate_number
		, drivers_license.car_make
		, drivers_license.car_model
		, income.annual_income	
	from
		person
	left join 
		drivers_license on drivers_license.id = person.license_id
	left join 
		income on income.ssn = person.ssn
	
	)

   , info_crime_scene as ( -- first find hint related to crime murder in SQL CITY 
	
	SELECT
    	date
    	, 'Crime Report' as source_information
    	, GROUP_CONCAT(description, ',') AS descriptions
	FROM 
		crime_scene_report
	WHERE city = 'SQL City'
  		AND type = 'murder'
	GROUP BY date
	
	)
	
	, get_detail_witness as (
	-- based on information from info crime scene 
	-- Security footage shows that there were 2 witnesses. 
	-- The first witness lives at the last house on "Northwestern Dr". 
	-- The second witness, named Annabel, lives somewhere on "Franklin Ave".
	
	select 
		*
	from 
		master_person
	where (name like 'Annabel%' and address_street_name like 'Franklin Ave') 
	or (address_street_name like 'Northwestern Dr' and address_number in (select max(address_number) from master_person where address_street_name like 'Northwestern Dr'))  
	
	
	)
	

	
	, check_interview_script_from_witnerr as (
	
	select *
	from 
		interview
	join 
		get_detail_witness on get_detail_witness.id = interview.person_id
	
	
	)
	
	-- theres two hint from this transcipt
	-- the killer check in the gym in january 9th 
	-- the killer have session together with annabel miller 16371
    -- the killer have gold membership and place h42 w
	
	, identify_the_killer as (
	
	select 
		get_fit_now_check_in.*
		, get_fit_now_member.person_id
		, get_fit_now_member.name
		, get_fit_now_member.membership_status
		, master_person.plate_number
	from 
		get_fit_now_check_in
	left join 
		get_fit_now_member on get_fit_now_member.id = get_fit_now_check_in.membership_id
	left join 
		master_person on get_fit_now_member.person_id = master_person.id
	where 
	   get_fit_now_member.membership_status = 'gold'
	and check_in_date like '%0109'
	and master_person.plate_number like '%H42W%'

	)

    
	select *
	from 
		interview
	join 
		get_detail_witness on get_detail_witness.id = interview.person_id
	
	
	)
	
	
	I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.