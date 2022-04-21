USE ORG;

-- show the employees3 table
select *
from employees3;

-- show the salaries3 table
select *
from salaries3;

-- print the departments with the average salary per employee lower than 700
select department_name, avg(salary) as avgSalary
from employees3 as e
inner join salaries3 as s
using(employee_id)
group by department_name
having avgSalary<700
order by avgSalary;

-- or

with selected as
(
select e.department_name, s.salary
from employees3 as e
inner join salaries3 as s
using (employee_id)
)
select department_name, avg(salary) as avgSalary
from selected
group by department_name
having avgSalary<700;

-- print departments that the average salary per employee is lower than 700 considering that some salaries are NULL. Assume 200$ for the NULLs.
select department_name, avg(coalesce(salary,200)) as avgSalary
from employees3 as e
inner join selected as s
using(employee_id)
group by department_name
having avgSalary<700
order by avgSalary;

-- or

with selected as
(
select employee_id, coalesce(salary,200) as salary
from salaries3
)
select department_name, avg(salary) as avgSalary
from employees3 as e
inner join selected as s
using(employee_id)
group by department_name
having avgSalary<700
order by avgSalary;

-- print departments that average salary per employee is lower than 700 (some salaries are NULL). Replace the department average salary for the NULL values.
with selected as
(
select employee_id, department_name, avg(salary) as avgSal
from employees3
inner join salaries3
using(employee_id)
group by department_name
)
select department_name, avg(coalesce(salary,avgSal)) as avgSalary
from selected
inner join salaries3
using(employee_id)
group by department_name
having avgSalary<700
order by avgSalary;

-- or

with selected1 as
(
select employee_id, department_name, avg(salary) as avgSalary
from employees3 as e
inner join salaries3 as s	
using (employee_id)
group by department_name
), selected2 as
(
select department_name, coalesce(salary,avgSalary)as salary2
from selected1 as s1
inner join salaries3 as s
using (employee_id)
)
select department_name, avg(salary2) as avgSalary2
from selected2
group by department_name
having avgSalary2<700;

-- show the trades2 table
select *
from trades2;

-- show the users table
select *
from users;

-- write a query to list the top 3 cities which had the highest number of completed orders 
select city, status2, count(status2) as statCount
from users
inner join trades2
using(user_id)
group by city, status2
having status2="complete"
order by statCount desc
limit 3;

-- or

select city, status2, count(status2) as statCount
from users
inner join trades2
using(user_id)
where status2="complete"
group by city
order by statCount desc
limit 3;




