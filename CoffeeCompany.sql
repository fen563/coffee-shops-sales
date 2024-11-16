select *
from city;

Create table customers
(customer_id INT Primary Key,
customer_name TEXT,
city_id INT,
Foreign Key(city_id) REFERENCES city(city_id)
);

select *
from customers;

create table products
(product_id INT Primary Key,
product_name TEXT,
price FLOAT
);

select *
from products;

create table sales(
sale_id INT PRIMARY KEY,
sale_date DATE,
product_id INT,
customer_id INT,
total FLOAT,
rating FLOAT,
CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

select * from sales;
select * from customers;
select * from products;
select * from city;

--Customer count from each city.
select city_name, population, count(DISTINCT s.customer_id) as Total_customer, sum(total) as total_revenue_Ruppee 
from sales s
join customers sc on s.customer_id = sc.customer_id
join city ct on sc.city_id = ct.city_id
group by city_name, population
order by total_customer desc;


--Revenue genrated in 4th Quarter.
select (sum(total)/84) as TotalRevenue_$, 
(select (sum(total/84)) from sales where sale_date between '2023-10-01' and '2024-01-01')as forthQ_Revenue,
(select (sum(total)/84)/(select (sum(total/84)) from sales where sale_date between '2023-10-01' and '2024-01-01'))as percentage
from sales;

--select sum(total) from sales where sale_date between '2023-10-01' and '2023-12-31'

--Sales count for each product
select product_name, price as product_value, count(*)as total_solditems, sum(total) as Total_revenue
from sales s
join products pd on s.product_id = pd.product_id
group by product_name, price
order by count(*) desc;

--------
--Top Selling product by city
--top 3 selling products in each city based on sales volume?
select * from city;
select * from products;
--cant use where clause on RANK bc its not actual column.
--There for we have to make a subquary or make a new table

Create table TopSelling_Product_BY_CITY
as
(select city_name, product_name, count(sale_id) as number_of_item_sold,
DENSE_RANK()Over(partition by city_name order by count(sale_id) Desc) as Rank
from sales s
join customers sc on s.customer_id = sc.customer_id
join city ct on sc.city_id = ct.city_id
join products pd on s.product_id = pd.product_id
group by city_name, product_name
order by city_name, count(sale_id) desc);

select *
from TopSelling_Product_BY_CITY
where rank <= 3;

------------

select * 
from sales s
join customers sc on s.customer_id = sc.customer_id
join city ct on sc.city_id = ct.city_id
join products pd on s.product_id = pd.product_id;

-------------
--monthly sales:

Create table monthly_sales
as
SELECT sale_id, sale_date, total, EXTRACT(MONTH from sale_date) as Month
FROM SALES
ORDER BY EXTRACT(MONTH from sale_date);

select month, sum(total) as total_revenue_per_month, (select sum(total) from sales) as total_revenue,
(sum(total)/ (select sum(total) from monthly_sales))*100 as monthly_percentage_revenue
from monthly_sales
group by month
order by month;

----

------

----Calculate the perecentage growth or decline rate in sales over differenct time periods (monthly) by each city:

select sum(total), city_name, Extract(Year from sale_date)as year 
from sales s
join customers sc on s.customer_id = sc.customer_id
join city ct on sc.city_id = ct.city_id
group by city_name, year
order by city_name, year;


select city_name, year, month, total_sales, ((total_sales - previous_month_sale)/total_sales)*100 as growth_rate
from
(select city_name, year, month, Total_sales, 
LAG(total_sales,1)Over(partition by city_name) as previous_month_sale
from 
(select sum(total) as total_sales, city_name, Extract(Month from sale_date)as month, Extract(Year from sale_date)as year 
from sales s
join customers sc on s.customer_id = sc.customer_id
join city ct on sc.city_id = ct.city_id
group by 2,4,3
order by 2,4) as table2) as table3;

-----
-----

--Total customer count, type of prodcuts sold, total_revenue
--Which city has possibility of opening new store??
select city_name, count(Distinct sc.customer_id) as customer_count, count(distinct pd.product_id) as different_product_type_count,
sum(total) as total_revenue_per_city, estimated_rent, ((sum(total)-estimated_rent)/sum(total))*100 as profit_margin
from sales s
join customers sc on s.customer_id = sc.customer_id
join city ct on sc.city_id = ct.city_id
join products pd on s.product_id = pd.product_id
group by city_name, estimated_rent
order by ((sum(total)-estimated_rent)/sum(total))*100 desc;

-----

CREATE TABLE sql_intv_q_1 (
   FoodId varchar(100) not null,
   Food varchar(100) not null,
   Date timestamp not null,
   Revenue float not null
);

INSERT INTO sql_intv_q_1(FoodId,Food,Date,Revenue)
VALUES ('123','Sushi','01/01/2022',50),
       ('123','Sushi','02/01/2022',100),
       ('456','Pizza','03/01/2022',70),
       ('789','Pasta','04/01/2022',20),
       ('111','Tofu','01/01/2022',10),
       ('789','Pasta','05/01/2022',90),
       ('789','Pasta','06/01/2022',80),
       ('789','Pasta','07/01/2022',80);

with main as
(SELECT *
FROM sql_intv_q_1),

grouping as
(SELECT foodid, food, MAX(revenue) as max_revenue
FROM sql_intv_q_1
group by food, foodid)

select t1.foodid, t1.food, t1.date, t1.revenue
from main t1
join grouping as t2 on t1.foodid = t2.foodid
				and t1.revenue = t2.max_revenue

SELECT * 
FROM sql_intv_q_1  
WHERE revenue IN(SELECT MAX(revenue) AS revenue FROM sql_intv_q_1 GROUP BY foodid)

-----



				
