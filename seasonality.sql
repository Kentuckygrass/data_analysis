select website_session_id,
created_at,
hour(created_at) as hr,
quarter(created_at) as qtr,
month(created_at) as mo,
weekday(created_at) as week_day
from website_sessions
where website_session_id between 150000 and 155000;

-- ******************************** --

select year(t1.created_at) as yr, 
month(t1.created_at) as mo, 
count(t1.website_session_id) as sessions, 
count(t2.order_id) as orders
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at >= '2012-01-01' and t1.created_at < '2013-01-01'
group by yr, mo;


-- ******************************** --

create temporary table table_5
select date(created_at) as day_date, 
weekday(created_at) as week_day,
hour(created_at) as hr,
count(website_session_id) as sessions
from website_sessions
where created_at between '2012-09-15' and '2012-11-15'
group by day_date, week_day, hr;

select * from table_5;

select
hr,
round(avg(case when week_day = 0 then sessions else null end),1) as mon,
round(avg(case when week_day = 1 then sessions else null end),1) as tue,
round(avg(case when week_day = 2 then sessions else null end),1) as wed,
round(avg(case when week_day = 3 then sessions else null end),1) as thu,
round(avg(case when week_day = 4 then sessions else null end),1) as fri,
round(avg(case when week_day = 5 then sessions else null end),1) as sat,
round(avg(case when week_day = 6 then sessions else null end),1) as sun
from table_5
group by hr
order by hr;






