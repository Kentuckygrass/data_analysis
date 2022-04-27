create temporary table session_to_order
select t1.website_session_id, t1.created_at, t2.order_id
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at < '2012-11-27'
and utm_source = 'gsearch';

select * from session_to_order;

select year(created_at) as yr,
month(created_at) as mo,
count(website_session_id) as month_session,
count(order_id) as month_order
from session_to_order
group by month(created_at);


-- -------------------- --
create temporary table campaign_session_order_v2
select t1.website_session_id, t1.created_at, t1.utm_campaign, t2.order_id
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at < '2012-11-27'
and utm_source = 'gsearch'
and utm_campaign in ('nonbrand', 'brand');

select * from campaign_session_order_v2;

select month(created_at) as mo,
count(case when utm_campaign = 'nonbrand' then website_session_id else null end) as nonbrand_session,
count(case when utm_campaign = 'nonbrand' and order_id is not null then website_session_id else null end) as nonbrand_order,
count(case when utm_campaign = 'brand' then website_session_id else null end) as brand_session,
count(case when utm_campaign = 'brand' and order_id is not null then website_session_id else null end) as brand_order
from campaign_session_order_v2
group by month(created_at);

-- ----------------- --
create temporary table device_session_order
select t1.website_session_id, t1.created_at, t1.device_type, t2.order_id
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at < '2012-11-27'
and utm_source = 'gsearch'
and utm_campaign ='nonbrand';

select * from device_session_order;

select year(created_at) as yr,
month(created_at) as mo,
count(case when device_type = 'desktop' then website_session_id else null end) as desktop_session,
count(case when device_type = 'desktop' then order_id else null end) as desktop_order,
count(case when device_type = 'mobile' then website_session_id else null end) as mobile_session,
count(case when device_type = 'mobile' then order_id else null end) as mobile_order
from device_session_order
group by month(created_at);

-- ----------------- --
select month(created_at) as mo, 
count(case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_session,
count(case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_session,
count(case when utm_source is null and http_referer is not null then website_session_id else null end) as organic_session,
count(case when utm_source is null and http_referer is null then website_session_id else null end) as direct_session
from website_sessions
where created_at < '2012-11-27'
group by month(created_at);


-- ------------------ --
select month(t1.created_at) as mo,
count(t1.website_session_id) as month_session,  
count(t2.order_id) as month_order,
count(t2.order_id) /count(t1.website_session_id) as conversion_rate
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at < '2012-11-27'
group by month(t1.created_at);

-- ------------------ --
select min(website_pageview_id) as first_test_pv
from website_pageviews
where pageview_url = '/lander-1';

create temporary table session_first_pageview
select t1.website_session_id,
min(t1.website_pageview_id) as min_pageview_id
from website_pageviews as t1
inner join website_sessions as t2
on t1.website_session_id = t2.website_session_id
and t2.created_at < '2012-07-28'
and t1.website_pageview_id >= 23504
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by t1.website_session_id;

select * from session_first_pageview;

create temporary table session_landing_page
select t1.website_session_id,
t2.pageview_url as landing_page
from session_first_pageview as t1
left join website_pageviews as t2
on t1.website_session_id = t2.website_session_id
where t2.pageview_url in ('/home', '/lander-1');

select * from session_landing_page;

create temporary table session_landing_order
select t1.website_session_id, t1.landing_page, t2.order_id
from session_landing_page as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id;

select * from session_landing_order;

select landing_page, 
count(website_session_id) as sessions,
count(order_id) as orders,
count(order_id)/count(website_session_id) as conversion_rate
from session_landing_order
group by landing_page;


-- ------------------ --
create temporary table table_v2
select t1.website_session_id,
pageview_url,
case when pageview_url = '/home' then 1 else 0 end as home_page,
case when pageview_url = '/lander-1' then 1 else 0 end as lander1_page,
case when pageview_url = '/products' then 1 else 0 end as products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url = '/billing' then 1 else 0 end as billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page 
from website_sessions as t1
left join website_pageviews as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at > '2012-06-19'
and t1.created_at < '2012-07-28'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
and pageview_url in ('/home','/lander-1', '/products', '/the-original-mr-fuzzy',
'/cart','/shipping','/billing','/thank-you-for-your-order');


select * from table_v2;

create temporary table table_4
select website_session_id,
max(home_page) as homepage,
max(lander1_page) as lander1,
max(products_page) as product_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it,
max(cart_page) as cart_made_it,
max(shipping_page) as shipping_made_it,
max(billing_page) as billing_made_it,
max(thank_page) as thank_made_it
from table_v2
group by website_session_id
order by website_session_id;

select * from table_4;

select 
case 
	when homepage = 1 then 'saw_homepage'
	when lander1 = 1 then 'saw_lander1'
	else 'check logic'
end as segment,
count(website_session_id) as sessions,
sum(product_made_it),
sum(mrfuzzy_made_it),
sum(cart_made_it),
sum(shipping_made_it),
sum(billing_made_it),
sum(thank_made_it)
from table_4
group by segment;


-- ------------------- --
create temporary table session_order_v2
select t1.website_session_id,
t1.pageview_url as billing_version,
t2.order_id,
t2.price_usd
from website_pageviews as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at > '2012-09-10'
and t1.created_at < '2012-11-10'
and pageview_url in ('/billing', '/billing-2');

select * from session_order_v2;

select billing_version,
count(website_session_id) as session,
sum(price_usd)/count(website_session_id) as revenue_per_session
from session_order
group by billing_version;

select count(website_session_id),pageview_url
from website_pageviews
where pageview_url in ('/billing', '/billing-2')
and created_at between '2012-10-27' and '2012-11-27'
group by pageview_url;