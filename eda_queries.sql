-- select top 1 restaurants by cuisine type without using limit and top func
with cte as (
select cuisine,restaurant_id,count(*) as no_of_orders       
from orders
group by restaurant_id,cuisine
order by cuisine,no_of_orders DESC)

select * from
(select *,ROW_NUMBER()OVER(PARTITION BY cuisine) as top_res
from cte)
where top_res=1;

--find the daily new customer from the launch date
select count(customer_code),dates
from (select customer_code,MIN(placed_at::date) as dates
from orders
GROUP BY customer_code
order by dates)
group by dates;

--count all the users who are acquired in jan25 and placed only one order 
--and did not place any order

with cte1 as (select customer_code,count(*) as num
from (
  select *,extract(month from placed_at) as dates
  from orders)
where dates=1
group by customer_code)

select customer_code
from cte1
where num=1 and customer_code not in(
  select customer_code
  from orders 
  where extract(month from placed_at) !=1);


--list all the customers that who don't order in last 7 days, and they acquired in last month
--with promo code
with cte as(
select customer_code,promo_code_Name
from orders
where (placed_at not between '2025-03-31' and '2025-03-24'))

select *
from cte
where promo_code_Name is not null;


--send message to customers for their every third order
SELECT *
FROM(select customer_code,ROW_NUMBER()OVER(PARTITION BY customer_code order by placed_at) as rn
from orders)
WHERE rn%3=0;

--list all the customers who placed more than 1 order and all orders on promo only
select *
from(select customer_code,count(*) as num_orders
from orders
where promo_code_Name is not null
group by customer_code)
where num_orders>1;

--num of customers acquired in jan by organically(no promo code used)

with cte as(select customer_code,promo_code_Name,row_number()over(partition by customer_code order by placed_at)as rs
from orders
where extract(month from placed_at)=1)

select count(case when rs=1 and promo_code_Name is null then customer_code end)*100/count(distinct customer_code)
from cte;












  


