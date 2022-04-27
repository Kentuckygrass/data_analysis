select primary_product_id,
count(order_id) as orders,
sum(price_usd) as revenue,
sum(price_usd - cogs_usd) as margin,
avg(price_usd) as aov
from orders
where order_id between 10000 and 11000
group by primary_product_id
order by primary_product_id;

-- ******************************** --

select year(created_at) as yr,
month(created_at) as mo,
count(order_id) as number_of_sales,
sum(price_usd) as total_revenue,
sum(price_usd - cogs_usd) as total_margin
from orders
where created_at < '2013-01-04'
group by yr, mo;

-- ******************************** --
select 
	year(t1.created_at) as yr, 
	month(t1.created_at) as mo,
	count(order_id ) as orders,
	count(order_id)/count(t1.website_session_id) as conversion_rate,
	sum(price_usd)/count(t1.website_session_id) as revenue_per_session,
	count(case when primary_product_id = 1 then order_id else null end) as product_one_orders,
	count(case when primary_product_id = 2 then order_id else null end) as product_two_orders
from website_sessions as t1
	left join orders as t2
		on t1.website_session_id = t2.website_session_id
where t1.created_at > '2012-04-01' and t1.created_at < '2013-04-05'
group by yr, mo;

-- ******************************** --
select distinct pageview_url
from website_pageviews;

select pageview_url,
count(t1.website_session_id) as sessions,
count(t2.order_id) as orders,
count(t2.order_id)/count(t1.website_session_id) as view_page_to_order_rate
from website_pageviews as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at between '2013-02-01' and '2013-03-01'
and pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear')
group by pageview_url;


-- ******************************** --
create temporary table pageview_from_product
select date(created_at) as dt,
website_session_id,
pageview_url
from website_pageviews
where created_at > '2012-10-06' and created_at < '2013-04-06'
and pageview_url in ('/products', '/the-original-mr-fuzzy', '/the-forever-love-bear');

select * from pageview_from_product;

create temporary table productpage_to_bearpage
select 
case when dt < '2013-01-06' then 'A.Pre_Product_2'
	 when dt >= '2013-01-06' then 'B.Post_Product_2'
	 else 'check'
     end as time_period,
count(case when pageview_url = '/products' then website_session_id else null end) as sessions,
count(case when pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear') then website_session_id else null end) as next_page,
count(case when pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end) as to_mrfuzzy,
count(case when pageview_url = '/the-forever-love-bear' then website_session_id else null end) as to_lovebear
from pageview_from_product
group by time_period;

select * from productpage_to_bearpage;

select time_period, sessions, next_page, 
next_page/sessions as pct_to_nextpage,
to_mrfuzzy/sessions as pct_to_mrfuzzy,
to_lovebear/sessions as pct_to_lovebear
from productpage_to_bearpage;

-- ******************************** --
create temporary table session_product_page
select website_session_id,
website_pageview_id,
pageview_url
from website_pageviews
where created_at > '2013-01-06' and created_at < '2013-04-10'
and pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear')
order by website_session_id;

select * from session_product_page;

select *
from session_product_page
left join website_pageviews
on session_product_page.website_session_id = website_pageviews.website_session_id;
-- and website_pageviews.website_pageview_id > session_product_page.website_pageview_id;


create temporary table table_3
select t1.website_session_id,
t1.pageview_url,
case when t2.pageview_url = '/cart' then 1 else 0 end as to_cart,
case when t2.pageview_url = '/shipping' then 1 else 0 end as to_shipping,
case when t2.pageview_url = '/billing-2' then 1 else 0 end as to_billing,
case when t2.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as to_thankyou
from session_product_page as t1
left join website_pageviews as t2
on t1.website_session_id = t2.website_session_id
and t2.website_pageview_id > t1.website_pageview_id; 

select * from table_3;

create temporary table table_5
select website_session_id,
pageview_url,
max(to_cart) as cart,
max(to_shipping) as shipping,
max(to_billing) as billing,
max(to_thankyou) as thankyou
from table_3
group by website_session_id;

select * from table_5;

select
case when pageview_url = '/the-original-mr-fuzzy' then 'mrfuzzy'
     when pageview_url = '/the-forever-love-bear' then 'lovebear'
     else 'check'
     end as product,
count(website_session_id) as sessions,
sum(cart) as to_cart,
sum(shipping) as to_shipping,
sum(billing) as to_billing,
sum(thankyou) as to_thankyou
from table_5
group by product
order by product;

-- Cross Selling Analysis --
select * 
from orders
where order_id between 10000 and 11000;

select *
from order_items
where order_id between 10000 and 11000; 

create temporary table cross_order_general
select orders.order_id,
orders.primary_product_id,
order_items.product_id as cross_sell_product
from orders
left join order_items
on orders.order_id = order_items.order_id
and order_items.is_primary_item = 0
where orders.order_id between 10000 and 11000;


select * from cross_order_general;

select primary_product_id,
count(distinct order_id) as orders,
count(case when cross_sell_product = 1 then order_id else null end) as x_sell_p1,
count(case when cross_sell_product = 2 then order_id else null end) as x_sell_p2,
count(case when cross_sell_product = 3 then order_id else null end) as x_sell_p3
from cross_order_general
group by primary_product_id;


-- Cross Selling Analysis Assignment--

create temporary table table_cart_shipping
select date(created_at) as dt,
website_session_id,
website_pageview_id,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as shipping_page
from website_pageviews
where created_at > '2013-08-25' and created_at < '2013-10-25'
and pageview_url in ('/cart', '/shipping');

select * from table_cart_shipping;

create temporary table number_cart_to_shipping
select dt,
website_session_id, 
max(cart_page) as to_cart_page,
max(shipping_page) as to_shipping_page
from table_cart_shipping
group by website_session_id;

select * from number_cart_to_shipping;

create temporary table table_cart_order_v2
select t1.dt,
t1.website_session_id,
t1.to_cart_page,
t1.to_shipping_page,
t2.order_id,
t2.items_purchased,
t2.price_usd
from number_cart_to_shipping as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id;

select * from table_cart_order_v2;

select 
case when dt < '2013-09-25' then 'A.Pre_Cross_Sell' 
	 when dt >= '2013-09-25' then 'B.Pre_Cross_Sell'
     else 'check'
     end as time_period,
sum(to_cart_page) as cart_sessions,
sum(to_shipping_page) as clickthrough,
sum(to_shipping_page)/sum(to_cart_page) as click_through_rate,
count(order_id) as orders,
sum(items_purchased) as products_amount,
sum(items_purchased)/count(order_id) as products_per_order,
sum(price_usd) as revenue,
avg(price_usd) as aov,
sum(price_usd)/sum(to_cart_page) as revenue_per_cart_session
from table_cart_order_v2
group by time_period;


-- Cross Selling Analysis Assignment2--

create temporary table session_order
select date(t1.created_at) as dt,
t1.website_session_id,
t2.order_id,
t2.items_purchased,
t2.price_usd
from website_sessions as t1
left join orders as t2
on t1.website_session_id = t2.website_session_id
where t1.created_at between '2013-11-12' and '2014-01-12';

select * from session_order;

select 
case when dt < '2013-12-12' then 'A.Pre_Birthday_Bear'
	 when dt >= '2013-12-12' then 'B.Post_Birthday_Bear'
     else 'Check'
     end as time_period,
count(website_session_id) as sessions,
count(order_id) as orders,
count(order_id)/count(website_session_id) as conversion_rate,
sum(items_purchased)/count(order_id) as products_per_order,
sum(price_usd) as revenue,
sum(price_usd)/count(website_session_id) revenue_per_session
from session_order
group by time_period;


-- Refund Assignment--

create temporary table order_refund
select year(t1.created_at) as yr,
month(t1.created_at) as mo,
t1.order_item_id,
t1.product_id,
t2.order_item_refund_id
from order_items as t1
left join order_item_refunds as t2
on t1.order_item_id = t2.order_item_id
where t1.created_at < '2014-10-15';

select * from order_refund;

select yr,
mo,
count(case when product_id = 1 then order_item_id else null end) as p1_orders,
count(case when product_id = 1 then order_item_refund_id else null end) as p1_refund,
count(case when product_id = 2 then order_item_id else null end) as p2_orders,
count(case when product_id = 2 then order_item_refund_id else null end) as p2_refund,
count(case when product_id = 3 then order_item_id else null end) as p3_orders,
count(case when product_id = 3 then order_item_refund_id else null end) as p3_refund
from order_refund
group by yr, mo;



