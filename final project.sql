select * from orders;

-- final project 1 -- 
select year(t1.created_at) as yr,
quarter(t1.created_at) as seasonality,
count(t1.website_session_id) as sessions,
count(t2.order_id) as orders
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
group by yr, seasonality;

-- final project 2 -- 

select year(t1.created_at) as yr,
quarter(t1.created_at) as seasonality,
count(t1.website_session_id) as sessions,
count(t2.order_id) as orders,
count(t2.order_id)/count(t1.website_session_id) as session_to_order_rate,
-- sum(price_usd) as revenue,
sum(price_usd)/count(t2.order_id) as revenue_per_order,
sum(price_usd)/count(t1.website_session_id) as revenue_per_session
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
group by yr, seasonality;


-- final project 3 -- 

create temporary table session_order_v2
select date(t1.created_at) as dt,
t1.website_session_id,
order_id,
utm_source, 
utm_campaign, 
http_referer
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id; 

select * from session_order_v2;

select 
year(dt) as yr,
quarter(dt) as seasonality,
count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end) as gsearch_nonbrand_order,
count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end) as bsearch_nonbrand_order,
count(case when utm_campaign = 'brand' then order_id else null end) as brand_order,
count(case when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then order_id else null end) as organic_order,
count(case when utm_source is null and http_referer is null then order_id else null end) as direct_type_in_order
from session_order_v2
group by yr, seasonality;

-- final project 4 -- 

select 
year(dt) as yr,
quarter(dt) as seasonality,
count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end)/
count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_session_id else null end) as gsearch_nonbrand_conv_rate,

count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end)/
count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_session_id else null end) as bsearch_nonbrand_conv_rate,

count(case when utm_campaign = 'brand' then order_id else null end)/
count(case when utm_campaign = 'brand' then website_session_id else null end) as brand_conv_rate,

count(case when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then order_id else null end)/
count(case when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then website_session_id else null end) as organic_conv_rate,

count(case when utm_source is null and http_referer is null then order_id else null end)/
count(case when utm_source is null and http_referer is null then website_session_id else null end) as direct_type_in_conv_rate
from session_order_v2
group by yr, seasonality;



-- final project 5 -- 


select year(t1.created_at) as yr,
quarter(t1.created_at) as qtr,
month(t1.created_at) as mo,
count(order_item_id) as total_sales,
t2.product_id,
sum(t2.price_usd) as revenue,
sum(t2.cogs_usd) as cost
from orders as t1
left join order_items as t2
on t1.order_id = t2.order_id
group by yr,qtr,mo,t2.product_id;


-- final project 6 -- 

select year(t1.created_at) as yr,
month(t1.created_at) as mo,
count(t1.website_session_id),
count(case when pageview_url = '/products' then t1.website_session_id else null end) as product_pageview,
count(case when pageview_url in ('/billing', '/billing-2') then t1.website_session_id else null end) as orders
from website_sessions as t1
left join website_pageviews as t2
on t1.website_session_id = t2.website_session_id
group by yr,mo;


-- final project 6 -- 
select * from order_items where created_at >= '2014-12-05';

create temporary table cross_sale_v2
select year(t1.created_at) as yr,
month(t1.created_at) as mo,
t1.order_id,
t1.primary_product_id,
t2.product_id,
is_primary_item
from orders as t1
left join order_items as t2
on t1.order_id = t2.order_id
where t1.created_at >= '2014-12-05'
and is_primary_item = 0;

select * from cross_sale_v2;

select 
yr,
mo,
primary_product_id,
count(case when product_id = 1 then order_id else null end) as cross_sale_1,
count(case when product_id = 2 then order_id else null end) as cross_sale_2,
count(case when product_id = 3 then order_id else null end) as cross_sale_3,
count(case when product_id = 1 then order_id else null end) as cross_sale_4
from cross_sale_v2
group by yr, mo,primary_product_id
order by yr, mo,primary_product_id;

