select * from website_pageviews;

select pageview_url,
count(website_pageview_id) as sessions
from website_pageviews
where website_pageview_id < 1000
group by pageview_url
order by sessions desc;


create temporary table first_pageview  -- 临时表
select website_session_id, 
min(website_pageview_id) as min_pageview_id
from website_pageviews
where website_pageview_id < 1000
group by website_session_id;

select * from first_pageview;

select fp.website_session_id,
pageview_url as entry_page
from first_pageview as fp
left join website_pageviews as wp
on fp.min_pageview_id = wp.website_pageview_id;

select count(website_pageview_id) as sessions, pageview_url
from website_pageviews
where date(created_at) < '2012-06-09'
group by pageview_url
order by sessions desc;


create temporary table landing_page
select website_session_id as sessions, min(website_pageview_id) as first_page
from website_pageviews
where created_at < '2012-06-12'
group by sessions;

select * from landing_page;

select count(landing_page.first_page) as entry_volume, 
	   website_pageviews.pageview_url 
from landing_page
left join website_pageviews
on landing_page.first_page = website_pageviews.website_pageview_id
group by website_pageviews.pageview_url
order by entry_volume desc;



-- finding the minimum website pageview id associated with each session we care about

select wp.website_session_id, min(wp.website_pageview_id)
from website_pageviews as wp
inner join website_sessions as ws
on wp.website_session_id = ws.website_session_id
where wp.created_at between '2014-01-01' and '2014-02-01'
group by wp.website_session_id;

create temporary table first_page_demo
select wp.website_session_id, min(wp.website_pageview_id) as first_pageview
from website_pageviews as wp
inner join website_sessions as ws
on wp.website_session_id = ws.website_session_id
where wp.created_at between '2014-01-01' and '2014-02-01'
group by wp.website_session_id;

select * from first_page_demo;

select first_page_demo.website_session_id, 
website_pageviews.pageview_url as landing_page
from first_page_demo
left join website_pageviews
on first_page_demo.first_pageview = website_pageviews.website_pageview_id;

create temporary table session_landing_page_demo
select first_page_demo.website_session_id, 
website_pageviews.pageview_url as landing_page
from first_page_demo
left join website_pageviews
on first_page_demo.first_pageview = website_pageviews.website_pageview_id;

select * from session_landing_page_demo;

select slpd.website_session_id, slpd.landing_page, count(wp.website_pageview_id) as count_page_viewed
from session_landing_page_demo as slpd
left join website_pageviews as wp
on slpd.website_session_id = wp.website_session_id
group by slpd.website_session_id
having count_page_viewed = 1;

create temporary table bounced_session_only
select slpd.website_session_id, slpd.landing_page, count(wp.website_pageview_id) as count_page_viewed
from session_landing_page_demo as slpd
left join website_pageviews as wp
on slpd.website_session_id = wp.website_session_id
group by slpd.website_session_id
having count_page_viewed = 1;

select * from bounced_session_only;

select slpd.website_session_id, slpd.landing_page, bso.website_session_id
from session_landing_page_demo as slpd
left join bounced_session_only as bso
on slpd.website_session_id = bso.website_session_id
order by slpd.website_session_id;

select slpd.landing_page, 
count(slpd.website_session_id), 
count(bso.website_session_id),
count(bso.website_session_id)/count(slpd.website_session_id) as bounce_rate
from session_landing_page_demo as slpd
left join bounced_session_only as bso
on slpd.website_session_id = bso.website_session_id
group by slpd.landing_page
order by slpd.website_session_id;


-- bounce rate assignment
create temporary table first_page_view
select website_session_id, min(website_pageview_id) as first_page_id
from website_pageviews
where created_at < '2012-06-14'
group by website_session_id; 

select * from first_page_view;

create temporary table landing_website
select fpv.website_session_id, wp.pageview_url
from first_page_view as fpv
left join website_pageviews as wp
on fpv.first_page_id = wp.website_pageview_id;

select * from landing_website;

create temporary table bounce_only
select website_session_id, count(website_pageview_id) as page_count
from website_pageviews
where created_at < '2012-06-14'
group by website_session_id
having page_count = 1;

select * from bounce_only;


select lw.pageview_url, 
count(lw.website_session_id) as sessions, 
count(bo.website_session_id) as bounced_sessions,
count(bo.website_session_id)/count(lw.website_session_id) as bounced_rate
from landing_website as lw
left join bounce_only as bo
on lw.website_session_id = bo.website_session_id
where pageview_url = '/home';


-- analyzing landing page test
select min(created_at), website_pageview_id from website_pageviews 
where pageview_url = '/lander-1';

create temporary table first_pageview_test
select wp.website_session_id, min(wp.website_pageview_id) as min_pageview_id
from website_pageviews as wp
inner join website_sessions as ws
on wp.website_session_id = ws.website_session_id
where ws.created_at  < '2012-07-28' 
and wp.website_pageview_id > 23504 
and utm_source = 'gsearch' 
and utm_campaign = 'nonbrand'
group by wp.website_session_id;


select * from first_pageview_test;

create temporary table landing_test
select first_pageview_test.website_session_id, 
website_pageviews.pageview_url
from first_pageview_test
left join website_pageviews
on first_pageview_test.min_pageview_id = website_pageviews.website_pageview_id
where website_pageviews.pageview_url in ('/home', '/lander-1');

select * from landing_test;

create temporary table bounce_session_test
select landing_test.website_session_id, count(website_pageview_id) as page_count
from landing_test
left join website_pageviews
on landing_test.website_session_id = website_pageviews.website_session_id
group by landing_test.website_session_id
having page_count = 1;

select * from bounce_session_test;

select t1.pageview_url, 
count(t1.website_session_id) as sessions, 
count(t2.website_session_id) as bounced_sessions,
count(t2.website_session_id)/count(t1.website_session_id) as bounce_rate
from landing_test as t1
left join bounce_session_test as t2
on t1.website_session_id = t2.website_session_id
group by pageview_url
order by t1.website_session_id;


-- paid search
select date(t1.created_at) as week_start_date, 
count(case when t1.pageview_url = '/home' then t1.website_pageview_id else null end) as home_volume,
count(case when t1.pageview_url = '/lander-1' then t1.website_pageview_id else null end) as lander1_volume
from website_pageviews as t1
inner join website_sessions as t2
on t1.website_session_id = t2.website_session_id
where t2.created_at between '2012-06-01' and '2012-08-31'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by week(t1.created_at);


create temporary table land_page_id_and_count_pageview_v2
select 
	date(website_sessions.created_at) as date_day,
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
    FROM website_pageviews
    JOIN website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
    AND website_pageviews.created_at > '2012-06-01' and website_pageviews.created_at < '2012-08-31'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
    GROUP BY website_sessions.website_session_id;

select * from land_page_id_and_count_pageview_v2;

create temporary table home_and_lander_v2
select t1.date_day, t1.website_session_id, t2.pageview_url, t1.count_pageviews
from land_page_id_and_count_pageview_v2 as t1
left join website_pageviews as t2
on t1.min_pv = t2.website_pageview_id
where pageview_url in ('/home', '/lander-1');

select * from home_and_lander_v2;

create temporary table home_lander_bounce_v2
select date_day, website_session_id, pageview_url, count_pageviews
from home_and_lander_v2
where count_pageviews = 1;

select * from home_lander_bounce_v2;

select t1.date_day as week_start_date, 
count(t2.website_session_id)/count(t1.website_session_id) as bounce_rate,
count(case when t1.pageview_url = '/home' then t1.website_session_id else null end) as home_session,
count(case when t1.pageview_url = '/lander-1' then t1.website_session_id else null end) as lander1_session
from home_and_lander_v2 as t1
left join home_lander_bounce_v2 as t2
on t1.website_session_id = t2.website_session_id
group by week(t1.date_day);



-- conversion funnel
select website_sessions.website_session_id,
	   website_pageviews.pageview_url,
	   website_pageviews.created_at as pageview_created_at,
       case when pageview_url = '/products' then 1 else 0 end as products_page,
       case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
       case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
	and website_pageviews.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart') 
order by website_sessions.website_session_id,
website_pageviews.created_at;


create temporary table session_level_made_it_flags_demo
select website_session_id,
max(products_page) as product_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it,
max(cart_page) as cart_made_it
from 
(
select website_sessions.website_session_id,
	   website_pageviews.pageview_url,
	   website_pageviews.created_at as pageview_created_at,
       case when pageview_url = '/products' then 1 else 0 end as products_page,
       case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
       case when pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
	on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
	and website_pageviews.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart') 
order by website_sessions.website_session_id,
website_pageviews.created_at
) as pageview_level
group by website_session_id;

select * from session_level_made_it_flags_demo;

select count(website_session_id), sum(product_made_it), sum(mrfuzzy_made_it), sum(cart_made_it)
from session_level_made_it_flags_demo;

select count(website_session_id), 
sum(product_made_it)/count(website_session_id) as through_lander_rate, 
sum(mrfuzzy_made_it)/sum(product_made_it) as through_product_rate, 
sum(cart_made_it)/sum(mrfuzzy_made_it) as through_mrfuzzy_rate
from session_level_made_it_flags_demo;


-- conversion funnel assignment 1
select distinct pageview_url from website_pageviews;


select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
case when pageview_url = '/products' then 1 else 0 end as products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url = '/billing' then 1 else 0 end as billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-08-5' and website_sessions.created_at < '2012-09-05'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
and website_pageviews.pageview_url 
in ('/lander-1', '/products', '/the-original-mr-fuzzy',
'/cart','/shipping','/billing','/thank-you-for-your-order')
order by website_sessions.website_session_id,
website_pageviews.created_at;



create temporary table conversion_level
select website_session_id,
max(products_page) as product_made_it,
max(mrfuzzy_page) as mrfuzzy_made_it,
max(cart_page) as cart_made_it,
max(shipping_page) as shipping_made_it,
max(billing_page) as billing_made_it,
max(thank_page) as thank_made_it
from 
(select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
case when pageview_url = '/products' then 1 else 0 end as products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url = '/billing' then 1 else 0 end as billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-08-5' and website_sessions.created_at < '2012-09-05'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
and website_pageviews.pageview_url 
in ('/lander-1', '/products', '/the-original-mr-fuzzy',
'/cart','/shipping','/billing','/thank-you-for-your-order')
order by website_sessions.website_session_id,
website_pageviews.created_at
) as session_level
group by website_session_id;

select * from conversion_level;

select count(website_session_id),
sum(product_made_it) as to_product,
sum(mrfuzzy_made_it) as to_mrfuzzy,
sum(cart_made_it) as to_cart,
sum(shipping_made_it) as to_shipping,
sum(billing_made_it) as to_billing,
sum(thank_made_it) as to_thank
from conversion_level;

select count(website_session_id),
sum(product_made_it)/count(website_session_id) as to_product_rate,
sum(mrfuzzy_made_it)/sum(product_made_it) as to_mrfuzzy_rate,
sum(cart_made_it)/sum(mrfuzzy_made_it) as to_cart_rate,
sum(shipping_made_it)/sum(cart_made_it) as to_shipping_rate,
sum(billing_made_it)/sum(shipping_made_it) as to_billing_rate,
sum(thank_made_it)/sum(billing_made_it) as to_thank_rate
from conversion_level;


-- conversion funnel assignment 2
select min(created_at), website_pageview_id from website_pageviews where pageview_url = '/billing-2';

create temporary table order_level_v2
select website_pageviews.website_session_id,
website_pageviews.pageview_url,
orders.order_id
from website_pageviews
left join orders
on website_pageviews.website_session_id = orders.website_session_id
where website_pageviews.created_at > '2012-09-10' and website_pageviews.created_at < '2012-11-10'
and website_pageviews.website_pageview_id >= 53550
and website_pageviews.pageview_url in ('/billing','/billing-2');

select * from order_level_v2;

select pageview_url, 
count(order_id) as orders, 
count(pageview_url) as sessions,
count(order_id)/count(pageview_url) as conversion_rate
from order_level
group by pageview_url;


