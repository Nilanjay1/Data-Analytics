create database doxim;
use doxim;
-- Write a query to fetch name, age and balance columns 
select Name, Age, Balance from bank;
-- List all customers and their details
select * from bank;
-- Find customers who have joined within the last year.
select `Customer id`, Name, Surname, `date joined` from bank
where `date joined`between date_sub((select max(`date joined`) from bank), interval 1 year) and (select max(`date joined`)from bank);
-- How can you update a date column stored as a string in a specific format to a proper DATE format in MySQL, and ensure that the column's data type is updated accordingly?
update bank
set `date joined`=str_to_date(`date joined`,'%d.%b.%y');
alter table bank
modify column `date joined` date;
select min(`date joined`),max(`date joined`)
from bank;
-- Retrieve customers with a balance greater than $5,000.
select `customer id`, name, surname, balance from bank
where balance>5000
order by balance desc;
-- Identify customers from a specific region, e.g., 'England'.
select `customer id`, name, surname, region, balance from bank
where region='england';
-- Find the average balance of all customers.
select avg(balance) as average_balance from bank;
-- List the top 10 customers with the highest balance.
select `customer id`, name, surname, balance from bank
order by balance desc
limit 10;
-- Count the number of customers in each region.
select region, count(`customer id`) as total_customers from bank
group by region
order by total_customers desc;
-- Identify the most common job classification among customers.
select `job classification`, count(`customer id`) as total_customers from bank
group by job
order by total_customers desc
limit 1;
-- Find the gender distribution of customers.
select gender, count(*) as total from bank
group by gender
order by total desc;
-- List all customers over 60 years old.
select `customer id`, name, surname, age from bank
where age>60;
-- Identify customers with the same surname.
select surname, group_concat(name) as same_surname from bank
group by surname
having count(*)>1;
-- Find customers whose names start with a specific letter, e.g., 'A'.
select `customer id`, name , surname from bank
where name like 'a%';
-- Calculate the total balance of all customers.
select sum(balance) as total_balance from bank;
-- List customers who have a balance between $1,000 and $10,000.
select `customer id`, name ,surname, balance from bank
where balance between 5000 and 10000;
-- Find customers by job classification and list their total balances.
select `job classification`, sum(balance) as total_balance from bank
group by `job classification`; 
-- Retrieve customers who live in a specific region and have a balance over $2,000.
select `customer id`, name, surname, region, balance from bank
where region='england' and balance>2000;
-- Calculate the average age of customers.
select avg(age) as average_age from bank;
-- List the youngest customer.
select `customer id`, name, surname, age from bank
order by age asc
limit 1;
-- Find the customer with the highest balance in each region.
select `customer id`, name, region, balance from(
select `customer id`, name, region, balance,
row_number() over(partition by region order by balance desc) as rnk
from bank ) as t
where rnk=1;
-- or
SELECT 
    b.region, 
    b.`customer id`, 
    b.name, 
    b.surname, 
    b.balance AS highest_balance
FROM 
    bank b
JOIN (
    SELECT 
        region, 
        MAX(balance) AS max_balance
    FROM 
        bank
    GROUP BY 
        region
) AS max_balances ON b.region = max_balances.region AND b.balance = max_balances.max_balance
LIMIT 0, 10;
-- Count the number of customers who joined in last month
select count(*) as total_customers from bank
where `date joined` between date_sub((select max(`date joined`) from bank), interval 1 month) and (select max(`date joined`) from bank);
-- or 
select count(*) as total_customers from bank
where `date joined`>= date_sub((select max(`date joined`) from bank), interval 1 month);
-- List customers who have a specific job classification and live in a specific region.
select `customer id`, name, surname, region, `job classification` from bank
where region = 'england' and `job classification`='white collar';
-- Find customers who are younger than the average customer age.
select `customer id`,name, surname, age from bank
where age < (select avg(age) from bank);
-- List customers whose first name is the same as their last name.
select `customer id`, name, surname from bank
where name=surname;
-- Find the number of customers who are male and female.
select gender, count(*) as total from bank
group by gender;
