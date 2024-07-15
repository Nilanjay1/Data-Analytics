/* 
Create a database named employee, then import data_science_team.csv proj_table.
csv and emp_record_table.csv into the employee database from the given resources.
*/

create database employees_performance;
use employees_performance;
select * from data_science_team;
select * from emp_record_table;
select * from proj_table;

/* Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, 
GENDER, and DEPARTMENT from the employee record table, 
and make a list of employees and details of their department.
*/

select emp_id, concat(first_name,' ', last_name) as fullname, gender, dept from emp_record_table;
/* Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, 
and EMP_RATING if the EMP_RATING is: 
•	less than two
•	greater than four 
•	between two and four
*/

select emp_id, concat(first_name,' ', last_name) as fullname, gender, dept,emp_rating from emp_record_table
where emp_rating<2 or emp_rating>4 or emp_rating between 2 and 4 ;

/*	Write a query to list only those employees who have someone reporting to them. 
Also, show the number of reporters (including the President).
*/

select * from emp_record_table
where emp_id in (select manager_id from emp_record_table);
select manager_id, count(*) from emp_record_table
group by manager_id;

/*	Write a query to list down all the employees from the healthcare and 
finance departments using union. Take data from the employee record table.
*/

select * from emp_record_table
where dept='finance'
union
select * from emp_record_table
where dept='healthcare';

/*	Write a query to list down employee details such as EMP_ID, FIRST_NAME, 
LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
Also include the respective employee rating along with the max emp rating for 
the department.
*/

select * from (
select emp_id, first_name, last_name, role, dept,emp_rating from emp_record_table
group by  emp_id, first_name, last_name, role, dept,emp_rating) as t1
inner join
(select dept,max(emp_rating) as max_rating from emp_record_table
group by dept) as t2
on t1.dept=t2.dept;

/*	Write a query to calculate the minimum and the maximum salary of the employees 
in each role. Take data from the employee record table.
*/

select role, max(salary) as max_salary, min(salary) as min_salary from emp_record_table
group by role;

/*	Write a query to assign ranks to each employee based on their experience. 
Take data from the employee record table.
*/

select emp_id, first_name, last_name, dept, exp, dense_rank() over (order by exp desc) as ranks from emp_record_table;

/*	Write a query to create a view that displays employees in various countries 
whose salary is more than six thousand. Take data from the employee record table.
*/

create view high_salary_emp as
select emp_id, first_name, last_name, dept, country, salary from emp_record_table
where salary>6000;
select * from high_salary_emp
order by salary desc;

/* 12.	Write a nested query to find employees with experience of more than ten years. 
Take data from the employee record table.
*/

select * from (
select * from emp_record_table
where exp>10) as t
order by exp desc;

/*	Write a query to create a stored procedure to retrieve the details of the 
employees whose experience is more than three years. 
Take data from the employee record table.
*/

create procedure get_exp_emp()
select * from emp_record_table
where exp>3;
CALL get_exp_emp();
select first_name, last_name, salary, exp,0.05*salary*emp_rating as bonus from emp_record_table;
select continent, country, avg(salary) as avg_salary from emp_record_table
group by continent,country
order by avg_salary;

/*
create view vw_emp as
select * from emp_record_table;
select * from vw_emp;
alter view vw_emp as
select * from emp_record_table
where dept='finance';
select * from vw_emp
order by exp desc;
start transaction;
delete from vw_emp;
rollback;
delimiter //
create procedure sp_emp()
begin
select* from data_science_team;
select * from emp_record_table;
select * from proj_table;
end //
delimiter ;
call sp_emp();
use store;
delimiter //
create procedure s_returns(in reg varchar(30))
begin
select * from orderdata as o
inner join returns as r
on o.`order id`=r.`order id`
where region=reg;
end //
delimiter ;
call s_returns ('east');
drop procedure s_returns;
delimiter //
create procedure sp_tables()
begin
drop table if exists tbl_cust;
drop table if exists tbl_prod;
create table tbl_cust as
select distinct `customer id`, `customer name` from orderdata;
create table tbl_prod as
select distinct `product id`, `product name`, category, `sub-category` from orderdata;
end //
delimiter ;
call sp_tables;
drop procedure sp_tables;
select * from tbl_cust;
select * from tbl_prod;
select continent, country, avg(salary) as avg_salary from emp_record_table
group by 1,2
order by avg_salary;
*/