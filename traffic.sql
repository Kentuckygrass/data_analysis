use mavenfuzzyfactory;
select * from website_sessions;
select distinct is_repeat_session from website_sessions;
select distinct utm_source from website_sessions;
select distinct utm_campaign from website_sessions;
select distinct utm_content from website_sessions;
select distinct device_type from website_sessions;
select distinct http_referer from website_sessions;


select ws.utm_content, 
count(ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
count(distinct o.order_id)/count(ws.website_session_id) as conversion_rate
from website_sessions as ws
left join orders as o
on ws.website_session_id = o.website_session_id
where ws.website_session_id between 1000 and 2000
group by ws.utm_content
order by sessions desc;


select utm_source, utm_campaign, http_referer, count(website_session_id) as sessions 
from website_sessions
where created_at < '2012-04-12'
group by utm_content, utm_campaign, http_referer
order by sessions desc;


select count(ws.website_session_id) as sessions, 
count(o.order_id) as orders,
count(o.order_id)/count(ws.website_session_id) as conversion_rate
from website_sessions as ws
left join orders as o
on ws.website_session_id = o.website_session_id
where ws.utm_source = 'gsearch' and ws.utm_campaign = 'nonbrand' and ws.created_at < '2012-04-14';


select week(created_at),
year(created_at),
min(date(created_at)) as week_start,
count(website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
group by 1,2;
 
 
select order_id, primary_product_id, items_purchased, created_at 
from orders
where order_id between 31000 and 32000;


select
primary_product_id,
count(distinct case when items_purchased = 1 then order_id else null end) as order_w_1_item,
count(distinct case when items_purchased = 2 then order_id else null end) as order_w_2_item,
count(distinct order_id) as total_orders
from orders
where order_id between 31000 and 32000
group by primary_product_id;


select min(date(created_at)) as week_start_date, 
count(website_session_id) as sessions
from website_sessions
where created_at between '2012-03-19' and '2012-05-12' and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by week(created_at);


select count(ws.website_session_id) as sessions, 
count(o.order_id) as orders, 
device_type,
count(o.order_id)/count(ws.website_session_id) as conversion_rate
from website_sessions as ws
left join orders as o
on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-05-11' and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by ws.device_type;


select min(date(created_at)) as week_start_date,
count(case when device_type = 'desktop' then website_session_id else null end) as desktop_sessions,
count(case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions
from website_sessions
where created_at between '2012-04-15' and '2012-06-09' 
and utm_source = 'gsearch' 
and utm_campaign = 'nonbrand'
group by week(created_at);
