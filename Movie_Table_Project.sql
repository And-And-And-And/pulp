
--Creating watch table for analysis
/*
drop table if exists moviewatchlist

create table moviewatchlist 
	(	ID int primary key,
		movie_name nvarchar(255),
		watch_date smalldatetime
		);

insert into MovieWatchlist (ID, movie_name, watch_date)
	values
		(1, 'Barbie', '2023-07-04 14:00')
	    ,(2, 'Barbie', '2023-08-13 15:30')
	    ,(3, 'Barbie', '2023-09-25 16:45')
	    ,(4, 'Barbie', '2023-08-26 19:15')
		,(5, 'TMNT', '2023-07-22 21:00')
		,(6, 'TMNT', '2023-08-19 21:00')
		,(7, 'Oppenheimer', '2023-09-01 20:00')
	    ,(8, 'Oppenheimer', '2023-09-26 22:30');

select * from moviewatchlist
*/

--1) Identify how many times Barbie was watched
	select *
		from moviewatchlist
		where movie_name = 'Barbie';

--2) Identify the number of times a movie was watched in August
	--2.1 extracting 7th character from the watch_date field and filtering on that value
		select count(*) as Count_of_August_Watches_2_1
			from moviewatchlist
			where substring(convert(nvarchar(255), watch_date, 120), 7, 1) = 8;

	--2.2 count records by extracting month from smalldatetime and filtering on that value
		select count(*) as Count_of_August_Watches_2_2
			from moviewatchlist
			where month(watch_date) = 8;

	--2.3 If the distinct months within the data is known then you can leverage dense_rank
		--2.3.1 Identify distinct months
			select distinct month(watch_date) as watch_month
				from MovieWatchlist;

		--2.3.2 dense_rank movies based on month 
			with MovieWatchlist_Months as
					(select
							id
							,movie_name
							,watch_date
							,month(watch_date) as watch_month
						from moviewatchlist
						)
				select 
						*
						,dense_rank() over (order by watch_month) as monthrank
					from MovieWatchlist_Months;

		--2.3.3 store data in memory to query on monthrank
			drop table if exists #MovieWatchlist_Months;

			with MovieWatchlist_Months as
					(select
							id
							,movie_name
							,watch_date
							,month(watch_date) as watch_month
						from moviewatchlist
						)
				select 
						*
						,dense_rank() over (order by watch_month) as monthrank
					into #MovieWatchlist_Months
					from MovieWatchlist_Months;

			--select * from #MovieWatchlist_Months;

			select count(*) as Count_of_August_Watches_2_3 
				from #MovieWatchlist_Months 
				where monthrank = 2;

			drop table if exists #MovieWatchlist_Months;

--3) Calculate the average days between two subsequent movie watches
	--3.1 Calculating the date differences
		with datedifferences as 
				(select
						ID,
						movie_name,
						watch_date,
						lag(watch_date) over (order by watch_date) as previouswatchdate
					from moviewatchlist
					)
			select
				    id,
				    movie_name,
				    watch_date,
				    datediff(day, previouswatchdate, watch_date) as daysdifference
				from datedifferences;

	--3.2 Calculating the average of the date differences
		with datedifferences as 
				(select
						ID,
						movie_name,
						watch_date,
						lag(watch_date) over (order by watch_date) as previouswatchdate
					from moviewatchlist
					)		
			select avg(daysdifference) as averagedaysdifference
				from (select
							id,
							movie_name,
							watch_date,
							datediff(day, previouswatchdate, watch_date) as daysdifference
						 from datedifferences) as differencequery


