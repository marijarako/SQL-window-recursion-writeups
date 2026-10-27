--AGGREGATES

--Count the number of facilities
select count(*) from cd.facilities

--Count the number of expensive facilities
select count(*)
from cd.facilities
where guestcost > 9

--Count the number of recommendations each member makes.
select recommendedby, count(*)
from cd.members 
where recommendedby is not null
group by recommendedby
order by recommendedby

--List the total slots booked per facility
select facid, sum(slots) from cd.bookings
group by facid
order by facid

--List the total slots booked per facility in a given month
select facid, sum(slots) from cd.bookings
where starttime >= '2012-09-01' and starttime < '2012-10-01'
group by facid
order by sum(slots)

--List the total slots booked per facility per month
select facid, EXTRACT(MONTH from starttime) as "month", sum(slots) as "Total Slots" 
from cd.bookings
where extract(YEAR from starttime) = 2012
group by month, facid
order by facid, extract(month from starttime)

--Find the count of members who have made at least one booking
select count(distinct(memid)) from cd.bookings

--List facilities with more than 1000 slots booked
select facid, sum(slots) as "Total Slots" from cd.bookings 
group by facid
having sum(slots)>1000
order by facid

--Find the total revenue of each facility
select f.name, sum(slots * case when memid = 0 
				  then f.guestcost 
				  else f.membercost
				  end) as revenue
from cd.bookings b join cd.facilities f on b.facid = f.facid
group by f.name
order by revenue

--Find facilities with a total revenue less than 1000
--using having
select f.name, sum(slots * case when memid=0
				  then f.guestcost
				  else f.membercost
				  end) as revenue
from cd.bookings b join cd.facilities f on b.facid=f.facid
group by f.name
having sum(slots * case when memid=0
				  then f.guestcost
				  else f.membercost
				  end) < 1000
order by revenue
--better way
select name, revenue from 
(select f.name, sum(slots * case when memid=0 then 
				   f.guestcost else f.membercost
				   end) as revenue
from cd.bookings b join cd.facilities f on b.facid = f.facid
group by f.name) as agg where revenue < 1000
order by revenuew

--Output the facility id that has the highest number of slots booked
select facid, sum(slots) from cd.bookings 
group by facid
order by sum(slots) desc
limit 1
--better way
select facid, sum(slots) from cd.bookings 
group by facid
having sum(slots) = (select max(sum2.totalslots) from 
		   (select sum(slots) as totalslots from cd.bookings
			group by facid) as sum2) 
--using CTE
with sum as (select facid, sum(slots) as totalslots
			from cd.bookings
			group by facid)
			
select facid, totalslots
from sum 
where totalslots = (select max(totalslots) from sum)

--List the total slots booked per facility per month, part 2
