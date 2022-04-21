USE ORG;

-- show the salaries table
select *
from salaries;

-- show the employees table
select *
from employees;

-- join the employees and salaries tables; fetch the average salary for each department as avgSalary
select e.department_name, avg(s.salary) as avgSalary
from employees as e
inner join salaries as s
using(employee_id)
group by department_name;

-- join the employees and salaries tables, fetch the maximum salary of each department as maxSalary
select e.department_name, max(s.salary) as maxSalary
from employees as e
inner join salaries as s
using(employee_id)
group by department_name;

-- fetch the employee identification and salary rank just according to the row number
select employee_id, employee_name, salary, row_number() over(order by salary desc) as rowNum
from salaries;

-- fetch the employee identification and salary rank so that the same salaries have the same rank and the next rank would be x+2 
select employee_id, employee_name, salary, rank() over(order by salary desc) as salaryRank
from salaries;

-- fetch the employee identification and salary rank so that the same salaries have the same rank and the next rank would be x+1 
select employee_id, employee_name, salary, dense_rank() over(order by salary desc) as salaryRank
from salaries;

-- fetch the data where the salaryRank is 2 and or 5
with selected as
(
select employee_id, employee_name, salary, dense_rank() over(order by salary desc) as salaryRank
from salaries
)
select *
from selected
where salaryRank=2 or salaryRank=5;

-- fetch all the data from salaries table ordered by salary, ascending
select *
from salaries
order by salary;

-- sort the employees based on their salary in their department
select e.department_name, e.employee_name, s.salary
from employees as e
inner join salaries as s
using(employee_id)
order by department_name, salary desc;

-- sort the employees based on their salary in their department and give them a rowNumber starts from 1 in each distinct department
select e.department_name, e.employee_name, s.salary, row_number() over(partition by department_name order by salary desc) as rowNum
from employees as e
inner join salaries as s
using(employee_id);

-- fetch the data (employee name, department, salary, and rowNumber) where the rowNumber is 1 and or 2 in each distinct department
with selected as
(
select e.department_name, e.employee_name, s.salary, row_number() over(partition by department_name order by salary desc) as rowNum
from employees as e
inner join salaries as s
using(employee_id)
)
select *
from selected
where rowNum<3;

-- fetch all data from the worker table
select *
from worker;

-- fetch the 4th salary from the worker table
select *
from worker
order by salary desc
limit 3,1;

-- fetch all the data for employees who receive the same amount of salary from the worker table
select *
from worker as w1
inner join worker as w2
where w1.salary=w2.salary and w1.worker_id<>w2.worker_id;

-- fetch all the data for employees who receive the same amount of salary (another way)
with selected as
(
select salary, count(worker_id) as workerCount
from worker
group by salary
having workerCount>1
)
select w.worker_id, w.first_name, w.last_name, w.salary
from worker as w
inner join selected as s
using (salary);

-- fetch the count of each department
select department, count(department) as departmentCount
from worker
group by department;

-- fetch all data of the last worker id
select *
from worker
order by worker_id desc
limit 1;

-- fetch all data of the last worker id (another way)
select *
from worker
where worker_id=(select max(worker_id) from worker);

-- fetch the department which its departmentCount is 4
select department, count(department) as departmentCount
from worker
group by department
having departmentCount=4;
