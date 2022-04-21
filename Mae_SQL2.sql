USE ORG;

-- show the department names and a new column called workersCount to show the count of workers in each department 
select department, count(worker_id) as workersCount
from worker
group by(department);

-- show the department names and a new column called workersCount to show the count of workers in each department and order the results by workersCount, ascending
select department, count(worker_id) as workersCount
from worker
group by(department)
order by workersCount;

-- show the department names and a new column called workersCount to show the count of workers in each department and order the results by workersCount, descending
select department, count(worker_id) as workersCount
from worker
group by(department)
order by workersCount desc;

-- show the department names and the maximum salary for each in a new column called maxSalary
select department, max(salary) as maxSalary
from worker
group by department
order by maxSalary desc;

-- show the department names and the average salary for each in a new column called avgSalary
select department, avg(salary) as avgSalary
from worker
group by department
order by avgSalary desc;

-- fetch the unique years indicated in the joining dates from the worker table
select distinct(year(date(joining_date))) as joinYear
from worker;

-- fetch the data from the worker table where the joining year is 2014 
select *
from worker
where year(date(joining_date))=2014;

-- fetch the data where the department is admin and salary is over 5000 
select *
from worker
where department="admin" and salary>5000;

-- fetch the employees count in every department 
select department, count(worker_id) as employeeCount
from worker
group by department
order by employeeCount desc;

-- show the title table
select *
from title;

-- show the title table
select *
from worker;

-- join the tow tables called worker and title; then fetch the first name, last name, department, and workers' title 
select w.first_name, w.last_name, w.department, t.worker_title
from worker as w
inner join title as t
on w.worker_id=t.worker_ref_id;

-- join the tow tables called worker and title; then fetch the first name, last name, department, and workers' title where the title is manager 
select w.first_name, w.last_name, w.department, t.worker_title
from worker as w
inner join title as t
on w.worker_id=t.worker_ref_id
where t.worker_title="manager";

-- show the count of managers as managerCount from the title table
select count(worker_ref_id) as managerCount
from title
where worker_title="manager";

-- fetch the count of workers for each distinct worker title
select worker_title, count(worker_ref_id) as employeeCount
from title
group by worker_title;

-- fetch the count of employees as employeeCount for every distinct title and joining date (affected_from)
select worker_title, affected_from as joining_date, count(worker_ref_id) as employeeCount
from title
group by worker_title,joining_date
order by worker_title,joining_date;

-- fetch all the data from the even rows of the worker table
select *
from worker
where mod(worker_id,2)=0;

-- fetch the data from the odd rows of the worker table 
select *
from worker
where mod(worker_id,2)=1;

-- fetch the data of the first 3 top salaries from the worker table
select *
from worker
order by salary desc
limit 3;

-- fetch the 3rd top salary from the worker table
select *
from worker
order by salary desc
limit 2,1;


