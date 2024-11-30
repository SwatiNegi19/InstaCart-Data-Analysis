select count(*) from instacart_schema.aisles;
select count(*) from instacart_schema.departments;
select count(*) from instacart_schema.orders;
select count(*) from instacart_schema.products;
select count(*) from instacart_schema.order_products__prior;


select * from instacart_schema.aisles;
select * from instacart_schema.departments;
select * from instacart_schema.orders;
select * from instacart_schema.products limit 100;
select * from instacart_schema.order_products__prior limit 100;

select opp.*,prd.product_name, ord.user_id, ord.order_number, ord.order_dow, 
ord.order_hour_of_day, ord.days_since_prior_order, ais., dept.
from instacart_schema.order_products__prior as opp 
left join instacart_schema.products as prd on opp.product_id = prd.product_id 
left join instacart_schema.orders as ord on opp.order_id = ord.order_id
left join instacart_schema.aisles as ais on prd.aisle_id = ais.aisle_id 
left join instacart_schema.departments as dept on prd.department_id = dept.department_id 
limit 100;

create temporary table instacart_schema.instacart_final (
select opp.*,prd.product_name, ord.user_id, ord.order_number, ord.order_dow, 
ord.order_hour_of_day, ord.days_since_prior_order, ais., dept.
from instacart_schema.order_products__prior as opp 
left join instacart_schema.products as prd on opp.product_id = prd.product_id 
left join instacart_schema.orders as ord on opp.order_id = ord.order_id
left join instacart_schema.aisles as ais on prd.aisle_id = ais.aisle_id 
left join instacart_schema.departments as dept on prd.department_id = dept.department_id );

select * from instacart_schema.instacart_final limit 100;

# Q1. Mention the 3 most popular aisles among customers?
Select * from
(Select aisle, count(aisle) as cc,
RANK() OVER (ORDER BY count(aisle) desc) as RNK
from instacart_schema.instacart_final 
group by aisle) as ranked_aisles  
where RNK <= 3;

# Q2. Which departments have the highest rate of returning customers?
Select * from
(Select department, count(reordered) as total_count, sum(reordered) as reordered_count, 
(sum(reordered)/count(reordered)) as ratio,
RANK() OVER(order by (sum(reordered)/count(reordered)) desc) as RNK
from instacart_schema.instacart_final group by department) as deptRNK
where RNK<=3;

# Q3. Mention the products which have the highest rate of reorders?
select * from
(select product_name, count(reordered) as total_count, sum(reordered) as reordered_count,
(sum(reordered)/count(reordered))as ratio,
DENSE_RANK() OVER(order by (sum(reordered)/count(reordered)) DESC) as DENSE_RNK 
from instacart_schema.instacart_final group by product_name ) as prod_rate
where DENSE_RNK Between 2 AND 4;

# Q4. Mention the products which have the highest reorders?
SELECT * FROM 
(select product_name, count(reordered) as total_count, sum(reordered) as reordered_count, 
RANK() OVER(order by sum(reordered) desc) as RNK
from instacart_schema.instacart_final where product_name IS NOT NULL
group by product_name) as prod_rnk
WHERE RNK <= 3;

# Q5. Find out the products which attract the most unique number of customers?
Select * from 
(SELECT product_name, count(distinct user_id) as unique_customers,
RANK() OVER (ORDER BY count(distinct user_id) DESC) AS RNK
FROM instacart_schema.instacart_final
WHERE product_name IS NOT NULL
group by product_name) as unique_rnk
where RNK <= 3;