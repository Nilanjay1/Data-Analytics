use retail;

/* Create below transaction and fact tables using the raw transaction data provided:
●	Transaction table: Invoice number, customer id, product id, quantity, rate, date, time
●	Customer table: customer id, country
●	Product table: Product id, product name
*/ 
delimiter //
create procedure p_retail()
begin
drop table if exists tb_tx;
drop table if exists tb_cust;
drop table if exists tb_prod;
create table tb_tx as
select distinct invoiceno, customerid, stockcode as product_id, quantity, unitprice
as rate, invoicedate
from retails;
create table tb_cust as
select distinct customerid, country
from retails;
create table tb_prod as
select distinct stockcode as product_id, description as product_name
from retails;
end //
delimiter ;
call p_retail;
select * from tb_tx;
select * from tb_cust;
select * from tb_prod;

-- Create a report to get the country-wise breakup of:
-- most popular product/ most purchased product
select country, description, total from (
select
description, country, sum(quantity) as total, row_number()over(partition by country order by sum(quantity) desc)
as rnk from retails
group by description, country) t
where rnk=1
order by total desc;
-- least popular product/ least purchased product
select country, description, total from(
select 
description, country, sum(quantity) as total, row_number() over(partition by country order by sum(quantity) asc)
as rnk from retails
group by country, description) as t
where rnk=1
order by total asc;
-- monthly sale
select country,
year(date_part) as year,month(date_part) as month, sum(quantity) as total_quantity, sum(quantity*unitprice) 
as total_sale from retails
group by country,year(date_part), month(date_part)
order by total_sale desc,year(date_part), month(date_part);
-- OR
SELECT 
    country,
    DATE_FORMAT(date_part, '%Y-%m') AS month,
    SUM(quantity) AS total_quantity,
    SUM(quantity * unitprice) AS total_sales
FROM 
    retails
GROUP BY 
    country, DATE_FORMAT(date_part, '%Y-%m')
ORDER BY 
    country, month;
-- ●	Arrange the customers as per most loyal 
select customerid, count(quantity) as total_qantity from retails
group by customerid
order by total_qantity desc;
-- OR
select customerid, sum(quantity*unitprice) as total_sales from retails
group by customerid
order by total_sales desc;
-- OR
select customerid, count(quantity) as total_quantity, sum(quantity*unitprice) as total_sales,
(count(quantity)+sum(quantity*unitprice)) as loyal_customer from retails
group by customerid
order by loyal_customer desc;
-- Arrange the customer as per most frequent customer in last 2 months
select customerid,count(quantity) as total_quantity from retails
where datediff((select max(date_part) from retails), date_part)<=60
group by customerid
order by COUNT(*) desc;
-- Find maximum sale day of the previous week according to the day the report is run. 
-- The date needs to be kept dynamic
select date_part, sum(quantity*unitprice) as total_sales from retails
where datediff((select max(date_part) from retails), date_part) between 8 and 14
group by date_part
order by total_sales desc
limit 1;
-- most popular product/ most purchased product
select stockcode, sum(quantity) from retails
group by stockcode
order by sum(quantity) desc
limit 1;
-- least popular product/ least purchased product 
select stockcode, sum(quantity) from retails
group by stockcode
order by sum(quantity) asc
limit 1;
select* from (
select 'hightest selling' as type, stockcode, sum(quantity) as units from retails
group by stockcode
order by sum(quantity) desc
limit 1) as t
union
select* from (
select 'lowest selling' as type, stockcode, sum(quantity) as units from retails
group by stockcode
order by sum(quantity) asc
limit 1) as t1;
-- monthly sale
update retails
set invoicedate=str_to_date(invoicedate,'%c/%d/%Y %H:%I');
alter table retails
modify column invoicedate datetime;
-- ●	Divide them in 3 equal categories according to the total number of customers 
select *, case when frq > 200 then 'gold'
when frq > 100 then 'silver' 
else 'bronze' end as category from (
select customerid, count(*) as frq from retails
group by customerid
order by frq desc) as t

