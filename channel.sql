select utm_content, 
count(distinct t1.website_session_id) as sessions,
count(order_id) as orders,
count(order_id)/count(distinct t1.website_session_id) as conversion_rate
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at between '2014-01-01' and '2014-02-01'
group by utm_content
order by sessions desc;

-- ******************************** --
create temporary table table_1
select created_at,
website_session_id,
utm_source
from website_sessions
where created_at > '2012-08-22' and created_at < '2012-11-29'
and utm_source in ('gsearch', 'bsearch')
and utm_campaign = 'nonbrand';

select * from table_1;

select date(created_at),
count(case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_session,
count(case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_session
from table_1
group by week(created_at);

-- ******************************** --
create temporary table table_2
select website_session_id,
utm_source,
device_type
from website_sessions
where created_at > '2012-08-22' and created_at < '2012-11-30'
and utm_source in ('gsearch', 'bsearch')
and utm_campaign = 'nonbrand';

select * from table_2;

select 
utm_source,
count(website_session_id) as sessions,
count(case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
count(case when device_type = 'mobile' then website_session_id else null end)/count(website_session_id) as pct_mobile
from table_2
group by utm_source;

-- ******************************** --
create temporary table table_3_v2
select t1.device_type,
t1.utm_source,
t1.website_session_id,
t2.order_id
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at > '2012-08-22' and t1.created_at < '2012-09-19'
and utm_campaign = 'nonbrand'
and utm_source in ('gsearch', 'bsearch');

select * from table_3_v2;

select device_type,
utm_source,
count(website_session_id) as sessions,
count(order_id) as orders,
count(order_id)/count(website_session_id) as conversion_rate
from table_3_v2
group by device_type, utm_source
order by device_type asc;

-- ******************************** --
create temporary table table_5
select date(created_at) as year_day,
website_session_id,
device_type,
utm_source
from website_sessions
where created_at > '2012-11-04' and created_at < '2012-12-22'
and utm_campaign = 'nonbrand';

select * from table_5;

select min(year_day),
count(case when device_type = 'desktop' and utm_source = 'gsearch' then website_session_id else null end) as gsearch_desktop,
count(case when device_type = 'desktop' and utm_source = 'bsearch' then website_session_id else null end) as bsearch_desktop,

count(case when device_type = 'mobile' and utm_source = 'gsearch' then website_session_id else null end) as gsearch_mobile,
count(case when device_type = 'mobile' and utm_source = 'bsearch' then website_session_id else null end) as bsearch_mobile
from table_5
group by week(year_day);

-- ******************************** --
select
case 
	when http_referer is null then 'direct_type_in'
	when http_referer = 'https://www.gsearch.com' and utm_source is null then 'gsearch_organic'
	when http_referer = 'https://www.bsearch.com' and utm_source is null then 'bsearch_organic'
	else 'other'
end as traffic,
count(website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
group by 1
order by 2 desc;

-- ******************************** --
select distinct utm_source,
utm_campaign,
http_referer
from website_sessions
where created_at < '2012-12-23';


