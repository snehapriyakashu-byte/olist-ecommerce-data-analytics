create database olist_ecommerce;
use olist_ecommerce;
show databases;
use olist_ecommerce;
use olist_ecommerce;

create table orders (
order_id varchar(50) primary key,
customer_id varchar(50),
order_status varchar(30),
order_purchase_timestamp datetime,
order_approved_at datetime,
order_delivered_carrier_date datetime,
order_delivered_customer_date datetime,
order_estimated_delivery_date datetime);

show variables like 'local_infile';	
set global local_infile = 1;
show variables like 'local_infile';
load data local infile 'C:/Users/Asus/Desktop/orders2.csv'
into table orders
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;
select count(*) as total_orders
from orders;

use olist_ecommerce;

create table order_items (
order_id varchar(50),
order_item_id int,
product_id varchar(50),
seller_id varchar(50),
shipping_limit_date datetime,
price decimal(10,2),
freight_value decimal(10,2) );

load data local infile 'C:/Users/Asus/Desktop/items.csv'
into table order_items
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;
select count(*) as total_order_items
from order_items;

use olist_ecommerce;

create table products (
product_id varchar(50) primary key,
product_category_name varchar(100),
product_name_lenght int,
product_description_lenght int,
product_photos_qty int,
product_weight_g decimal(10,2),
product_length_cm decimal(10,2),
product_height_cm decimal(10,2),
product_width_cm decimal(10,2) );

load data local infile 'C:/Users/Asus/Desktop/product.csv'
into table products
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select count(*) as total_products
from products;

use olist_ecommerce;

create table customers (
customer_id varchar(50) primary key,
customer_unique_id varchar(50),
customer_zip_code_prefix int,
customer_city varchar(100),
customer_state varchar(10) );

load data local infile 'C:/Users/Asus/Desktop/customersr.csv'
into table customers
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select count(*) as total_customers
from customers;
use olist_ecommerce;

create table sellers (
seller_id varchar(50) primary key,
seller_zip_code_prefix int,
seller_city varchar(100),
seller_state varchar(10) );

load data local infile 'C:/Users/Asus/Desktop/seller.csv'
into table sellers
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select count(*) as total_sellers
from sellers;

use olist_ecommerce;

create table order_payments (
order_id varchar(50),
payment_sequential int,
payment_type varchar(30),
payment_installments int,
payment_value decimal(10,2) );

load data local infile 'C:/Users/Asus/Desktop/order payment.csv'
into table order_payments
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

use olist_ecommerce;

create table order_reviews (
review_id varchar(50),
order_id varchar(50),
review_score int,
review_comment_title text,
review_comment_message text,
review_creation_date datetime,
review_answer_timestamp datetime);

load data local infile 'C:/Users/Asus/Desktop/review.csv'
into table order_reviews
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select count(*) as total_reviews
from order_reviews;

use olist_ecommerce;

create table product_category (
product_category_name varchar(100),
product_category_name_english varchar(100) );

load data local infile 'C:/Users/Asus/Desktop/product cat.csv'
into table product_category
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select count(*) as total_categories
from product_category;

select 'orders' as table_name, count(*) as row_count from orders
union all
select 'order_items', count(*) from order_items
union all
select 'products', count(*) from products
union all
select 'customers', count(*) from customers
union all
select 'sellers', count(*) from sellers
union all
select 'order_payments', count(*) from order_payments
union all
select 'order_reviews', count(*) from order_reviews
union all
select 'product_category', count(*) from product_category;

select count(*) as orphan_orders
from orders o
left join customers c
on o.customer_id = c.customer_id
where c.customer_id is null;

select count(*) as orphan_order_items
from order_items oi
left join orders o
on oi.order_id = o.order_id
where o.order_id is null;

select count(*) as orphan_order_items
from order_items oi
left join products p
on oi.product_id = p.product_id
where p.product_id is null;

select count(*) as orphan_order_items
from order_items oi
left join sellers s
on oi.seller_id = s.seller_id
where s.seller_id is null;

select count(*) as orphan_payments
from order_payments op
left join orders o
on op.order_id = o.order_id
where o.order_id is null;

select count(*) as orphan_reviews
from order_reviews r
left join orders o
on r.order_id = o.order_id
where o.order_id is null;

select count(*) as products_without_category
from products p
left join product_category pc
on p.product_category_name = pc.product_category_name
where p.product_category_name is not null
  and pc.product_category_name is null;
  
select 
p.product_category_name,
count(*) as product_count
from products p
left join product_category pc
on p.product_category_name = pc.product_category_name
where p.product_category_name is not null
and pc.product_category_name is null
group by p.product_category_name
order by product_count desc;

-- total orders
use olist_ecommerce;
select count(*) as total_orders
from orders;

-- order items
select 
round(sum(price), 2) as total_sales
from order_items;

-- total customers
select 
count(distinct customer_unique_id) as total_customers
from customers;

-- Average Order Value
select round(sum(oi.price) / count(distinct oi.order_id), 2 ) as average_order_value
from order_items oi;

-- Average Review Score
select 
round(avg(review_score), 2) as average_review_score
from order_reviews;

-- Monthly Revenue Trend
select
date_format(o.order_purchase_timestamp, '%Y-%m') as month,
round(sum(oi.price), 2) as revenue
from orders o
join order_items oi
on o.order_id = oi.order_id
group by date_format(o.order_purchase_timestamp, '%Y-%m')
order by month;

-- Top 10 Product Categories by Revenue
select
coalesce(pc.product_category_name_english,
p.product_category_name,'Unknown') as category,
round(sum(oi.price), 2) as revenue
from order_items oi
join products p
on oi.product_id = p.product_id
left join product_category pc
on p.product_category_name = pc.product_category_name
group by
coalesce(pc.product_category_name_english,
p.product_category_name,'uknown')
order by revenue desc
limit 10;

-- Revenue by Payment Type
select
payment_type,
count(distinct order_id) as total_orders,
round(sum(payment_value), 2) as total_payment
from order_payments
group by payment_type
order by total_payment desc;

-- Delivery Performance
select
round( avg( datediff( order_delivered_customer_date, order_purchase_timestamp)),2) as average_delivery_days
from orders
where order_status = 'delivered' and order_delivered_customer_date is not null;
select
order_id,
order_status,
order_purchase_timestamp,
order_delivered_customer_date
from orders
where order_status = 'delivered'
limit 10;

select
count(*) as delivered_orders,
count(order_delivered_customer_date) as orders_with_delivery_date
from orders
where order_status = 'delivered';

select
order_id,
order_purchase_timestamp,
order_delivered_customer_date,
datediff(order_delivered_customer_date, order_purchase_timestamp ) as delivery_days
from orders
where order_status = 'delivered'
limit 10;

drop table orders;

create table orders (
order_id varchar(50) primary key,
customer_id varchar(50),
order_status varchar(30),
order_purchase_timestamp datetime,
order_approved_at datetime,
order_delivered_carrier_date datetime,
order_delivered_customer_date datetime,
order_estimated_delivery_date datetime );

load data local infile 'C:/Users/Asus/Desktop/orders2.csv'
into table orders
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(
order_id,
customer_id,
order_status,
@purchase,
@approved,
@carrier,
@customer_delivery,
@estimated )
set
order_purchase_timestamp = str_to_date(@purchase, '%Y-%m-%d %H:%i:%s'),
order_approved_at = str_to_date(nullif(@approved, ''), '%Y-%m-%d %H:%i:%s'),
order_delivered_carrier_date = str_to_date(nullif(@carrier, ''), '%Y-%m-%d %H:%i:%s'),
order_delivered_customer_date = str_to_date(nullif(@customer_delivery, ''), '%Y-%m-%d %H:%i:%s'),
order_estimated_delivery_date = str_to_date(@estimated, '%Y-%m-%d %H:%i:%s');
    
select count(*) as total_orders
from orders;

select
order_id,
order_purchase_timestamp,
order_delivered_customer_date
from orders
where order_status = 'delivered'
limit 10;

create table orders_staging (
order_id varchar(50),
customer_id varchar(50),
order_status varchar(30),
order_purchase_timestamp varchar(50),
order_approved_at varchar(50),
order_delivered_carrier_date varchar(50),
order_delivered_customer_date varchar(50),
order_estimated_delivery_date varchar(50));

load data local infile 'C:/Users/Asus/Desktop/orders2.csv'
into table orders_staging
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select
order_purchase_timestamp,
order_delivered_customer_date
from orders_staging
where order_purchase_timestamp <> ''
limit 10;

truncate table orders;

insert into orders (
order_id,
customer_id,
order_status,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date,
order_estimated_delivery_date)
select
order_id,
customer_id,
order_status,
str_to_date(nullif(order_purchase_timestamp, ''), '%d-%m-%Y %H:%i'),
str_to_date(nullif(order_approved_at, ''), '%d-%m-%Y %H:%i'),
str_to_date(nullif(order_delivered_carrier_date, ''), '%d-%m-%Y %H:%i'),
str_to_date(nullif(order_delivered_customer_date, ''), '%d-%m-%Y %H:%i'),
str_to_date(nullif(order_estimated_delivery_date, ''), '%d-%m-%Y %H:%i')
from orders_staging;

select
order_id,
order_purchase_timestamp,
order_delivered_customer_date
from orders
where order_status = 'delivered'
limit 10;

select
round(
avg(datediff(order_delivered_customer_date, order_purchase_timestamp)),2) as average_delivery_days
from orders
where order_status = 'delivered'and order_delivered_customer_date is not null;
  
  -- On-Time vs Late Delivery
  select
case
when order_delivered_customer_date <= order_estimated_delivery_date
then 'On Time'
else 'Late'
end as delivery_status,
count(*) as total_orders
from orders
where order_status = 'delivered'
and order_delivered_customer_date is not null
group by
case
when order_delivered_customer_date <= order_estimated_delivery_date
then 'On Time'
else 'Late'
end
order by total_orders desc;

select
round(100.0 * sum(case when order_delivered_customer_date <= order_estimated_delivery_date then 1 else 0 end ) / count(*),2 ) as on_time_percentage
from orders
where order_status = 'delivered'
and order_delivered_customer_date is not null;
  
  -- Customer Analysis
select
case
when order_count = 1 then 'One-Time Customer'
else 'Repeat Customer'
end as customer_type,
count(*) as total_customers
from (
select
c.customer_unique_id,
count(o.order_id) as order_count
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_unique_id
) as customer_orders
group by
case
when order_count = 1 then 'One-Time Customer'
else 'Repeat Customer'
end;
        
select
c.customer_unique_id,
round(sum(oi.price), 2) as total_spent
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.customer_unique_id
order by total_spent desc
limit 10;

-- Seller Performance Analysis
select
s.seller_id,
count(distinct oi.order_id) as total_orders,
count(oi.product_id) as total_items_sold,
round(sum(oi.price), 2) as total_sales
from sellers s
join order_items oi
on s.seller_id = oi.seller_id
group by s.seller_id
order by total_sales desc
limit 10;

-- Seller State Analysis
select
s.seller_state,
count(distinct oi.order_id) as total_orders,
round(sum(oi.price), 2) as total_sales
from sellers s
join order_items oi
on s.seller_id = oi.seller_id
group by s.seller_state
order by total_sales desc;

-- Review & Customer Satisfaction
select
review_score,
count(*) as total_reviews
from order_reviews
group by review_score
order by review_score;

-- Average Review Score by Payment Type
select
op.payment_type,
round(avg(r.review_score), 2) as average_review_score,
count(distinct r.order_id) as reviewed_orders
from order_payments op
join order_reviews r
on op.order_id = r.order_id
group by op.payment_type
order by average_review_score desc;

-- Order Status Analysis
select
order_status,
count(*) as total_orders,
round(100.0 * count(*) / (select count(*) from orders),2) as percentage_of_orders
from orders
group by order_status
order by total_orders desc;

-- Top 10 Products by Revenue
select
oi.product_id,
coalesce( pc.product_category_name_english,p.product_category_name, 'Unknown' ) as category,
count(oi.order_id) as items_sold,
round(sum(oi.price), 2) as total_sales
from order_items oi
join products p
on oi.product_id = p.product_id
left join product_category pc
on p.product_category_name = pc.product_category_name
group by
oi.product_id,
coalesce(
pc.product_category_name_english,
p.product_category_name,'Unknown' )
order by total_sales desc
limit 10;

-- Monthly Orders + Revenue
select
date_format(o.order_purchase_timestamp, '%Y-%m') as month,
count(distinct o.order_id) as total_orders,
round(sum(oi.price), 2) as revenue
from orders o
join order_items oi
on o.order_id = oi.order_id
group by date_format(o.order_purchase_timestamp, '%Y-%m')
order by month;

-- Average Order Value by Month
select
date_format(o.order_purchase_timestamp, '%Y-%m') as month,
round( sum(oi.price) / count(distinct o.order_id), 2 ) as average_order_value
from orders o
join order_items oi
on o.order_id = oi.order_id
group by date_format(o.order_purchase_timestamp, '%Y-%m')
order by month;

use olist_ecommerce;