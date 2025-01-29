USE ORG;

-- fetch all the data for the last 3 worker ids 
select *
from worker
order by worker_id desc
limit 3;

-- or

with selected as
(
select *
from worker
order by worker_id desc
limit 3
)
select *
from selected
order by worker_id asc;

-- fetch the sum of salary for each department 
select department, sum(salary) as totalSalary
from worker
group by department;

-- find the name of the worker who earns the highest salary
select *
from worker
where salary=(select max(salary) from worker);

-- find employees with highest second salary at each department from worker table along with their job title from title table 
with selected1 as
(
select w.first_name, w.last_name, w.salary, w.department, t.worker_title
from worker as w
inner join title as t
on w.worker_id=t.worker_ref_id
), selected2 as
(
select *, dense_rank() over(partition by department order by salary desc) as salaryRank
from selected1
)
select *
from selected2
where salaryRank=2;

-- print the name of employees whose joining date is between 2014-01-01 and 2014-04-01 
select *
from worker
where joining_date>date("2014-01-01") and date(joining_date)<date("2014-04-01");

-- print the name of employees whose joining date is between 2014-01-01 and 2014-04-01 if the joining_date is in form of string 
select *
from worker
where date(joining_date)>date("2014-01-01") and date(joining_date)<date("2014-04-01");

-- find the number of repetition of each department
select department, count(department)
from worker
group by department;

-- find the number of repetition of each first name
select first_name, count(first_name)
from worker
group by first_name;

-- fetch the repeated names and their count 
select first_name, count(first_name) as fnCount
from worker
group by first_name
having fnCount>1;

-- fetch all the employees whose last name starts with s from the worker table
select *
from worker
where last_name like "s%";

-- fetch all the employees whose last name lasts with l
select *
from worker
where last_name like "%l";

-- fetch all the employees whose last name contains m
select *
from worker
where last_name like "%m%";

-- show the current date
select curdate();

-- show the current year
select year(curdate());

-- fetch the name of workers with the same joining date 
with selected as
(
select joining_date, count(joining_date) as jdCount
from worker
group by joining_date
having jdCount>1
)
select *
from worker
where joining_date in (select joining_date from selected)
order by joining_date;

-- or

select *
from worker as w1
inner join worker as w2
where w1.worker_id<>w2.worker_id and w1.joining_date=w2.joining_date;

