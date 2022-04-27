-- Users Repeat Visiting --
create temporary table user_sessions_v2
select user_id,
count(website_session_id) as sessions
from website_sessions
where created_at >= '2014-01-01' and created_at < '2014-11-01'
group by user_id;

select * from user_sessions_v2;

select 
case when sessions = 1 then 0
     when sessions = 2 then 1
     when sessions = 3 then 2
     when sessions = 4 then 3
     else 'check'
     end as repeat_sessions,
count(user_id) as users
from user_sessions_v2
group by repeat_sessions;




-- Days between first and second --


create temporary table first_visit
select date(created_at) as first_date,
website_session_id,
user_id,
is_repeat_session
from website_sessions
where created_at >= '2014-01-01' and created_at < '2014-03-01'
and is_repeat_session = 0
order by website_session_id;

select count(*) from first_visit;

create temporary table second_visit
select date(created_at) as second_date,
min(website_session_id) as second_session,
user_id,
is_repeat_session
from website_sessions
where created_at >= '2014-01-01' and created_at < '2014-03-01'
and is_repeat_session = 1
group by user_id
order by website_session_id;

select * from second_visit
where user_id = 152881;


create temporary table visit
select first_date,
second_date,
t1.user_id as user_id
from second_visit as t1
inner join first_visit as t2
on t1.user_id = t2.user_id
order by user_id;

select avg(datediff(second_date, first_date)) as avg_day,  
min(datediff(second_date, first_date)) as min_day, 
max(datediff(second_date, first_date)) as max_day
from visit
order by user_id;

-- Repeat Session --

select 
case when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then 'organic_search'
	 when utm_campaign = 'nonbrand' then 'paid_nonbrand'
     when utm_campaign = 'brand' then 'paid_brand'
     when utm_source is null and http_referer is null then 'direct_type_in'
     when utm_source = 'socialbook' then 'paid_social'
end as channel_group,
count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from website_sessions
where created_at < '2014-11-05'
	  and created_at >= '2014-01-01'
group by 1
order by 3 desc;

-- Repeat Revenue --

create temporary table session_order
select is_repeat_session,
count(t1.website_session_id) as sessions,
count(t2.order_id) as orders,
sum(t2.price_usd) as revenue
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where is_repeat_session = 0
and t1.created_at >= '2014-01-01'
and t1.created_at < '2014-11-08'
union
select is_repeat_session,
count(t1.website_session_id) as sessions,
count(t2.order_id) as orders,
sum(t2.price_usd) as revenue
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where is_repeat_session = 1
and t1.created_at >= '2014-01-01'
and t1.created_at < '2014-11-08';

select * from session_order;

select is_repeat_session,
sessions,
orders/sessions as conv_rate,
revenue/sessions as rev_per_session
from session_order;
