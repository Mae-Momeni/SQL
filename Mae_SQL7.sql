USE ORG;

-- show the transaction table
select *
from transaction;

-- show the transaction_id and customer_id columns from the transaction table
select transaction_id, customer_id
from transaction;

-- show the transaction_id and customer_id columns where customer_id is Cust_8 
select transaction_id, customer_id
from transaction
where customer_id="Cust_8";

-- show the transaction_id and customer_id columns where customer_id is Cust_6 and or Cust-8, then order the results by both customer_id and then by transaction_id. 
select transaction_id, customer_id
from transaction
where customer_id="Cust_6" or customer_id="Cust_8"
order by customer_id, transaction_id;

-- show all the student table
select *
from student;

-- show all data where the id is less than 3 from the student table
select *
from student
where id<3;

-- show all data where id is less than 3 and or the score is more than 14
select *
from student
where id<3 or score>14;

-- show the average value of the score column 
select avg(score) as avgScore
from student;

-- show the average of the id and score columns
select avg(id) as avgId, avg(score) as avgScore
from student;

-- show the average of the score where the score is more than 15
select avg(score) as avgScore 
from student
where score>15;

-- show the maximum score
select max(score) as maxScore
from student;

-- show the minimum score 
select min(score) as minScore
from student;

-- order the data ascending by the score, then show the first and second rows
select *
from student
order by score
limit 2;

-- order the data descending by the score, then show the first and second rows 
select *
from student
order by score desc
limit 2;

-- show the worker table
select*
from worker;

-- -- show the FIRST_NAME column and rename it to fName
select FIRST_NAME as fName
from worker;

-- show the unique departments (not repetitive ones) mentioned in the department column
select distinct(department) as departments
from worker;

-- show the FIRST_NAME column and its length in a new column called LFN 
select FIRST_NAME as fName, length(FIRST_NAME) as LFN
from worker;

-- show the FIRST_NAME column and its length in a new column called LFN and order the results by LFN, ascending
select FIRST_NAME as fName, length(FIRST_NAME) as LFN
from worker
order by LFN; 

-- show the FIRST_NAME column and its length in a new column called LFN and order the results by LFN, ascending, at the first priority and by FIRST_NAME at the second priority
select FIRST_NAME as fName, length(FIRST_NAME) as LFN
from worker
order by LFN, FIRST_NAME;

-- show the FIRST_NAME followed by LAST_NAME with a space in between in a new column called Full_Name
select concat(FIRST_NAME, " ", LAST_NAME) as Full_Name
from worker;

-- show all the data where the FIRST_NAME is Vishal 
select *
from worker
where FIRST_NAME="Vishal";

-- show all data where the department is HR
select *
from worker
where department="HR";

-- show all data where the salary is over 100000
select *
from worker
where salary>100000;

-- show all the data where the salary is over 100000 and less than 400000
select *
from worker
where salary>100000 and salary<400000;

-- show all the data where the salary is over 100000 and less than 400000 and the department is HR 
select *
from worker
where salary>100000 and salary<400000 and department="HR";

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

-- show the employeedetails table
select *
from employeedetails;

-- show the employeesalary table
select *
from employeesalary;

-- show the personnel table
select *
from personnel;

-- show the personnel table
select *
from stocktable;

-- fetch name and id from personnel table
select fullname, empid
from personnel;

-- fetch the name, id, and shares for the workers who are in both personnel and stocktable tables
select p.empid, p.fullname, s.shares
from personnel as p
inner join stocktable as s
using(empid);

-- fetch the name, id, and shares of all people who are in the stocktable table 
select p.empid, p.fullname, s.shares
from personnel as p
right join stocktable as s
using(empid);  

-- fetch the name and id of people who are in the personnel table but not in the stocktable table 
select p.empid, p.fullname, s.shares
from personnel as p
left join stocktable as s
using(empid)
where shares is null;

-- fetch the name and shares of people who are in both tables (the primary way is using inner join but you use using left join to answer)
select p.empid, p.fullname, s.shares
from personnel as p
left join stocktable as s
using(empid)
where shares is not null;

-- inner join personnel and stocktable tables
select *
from personnel as p
inner join stocktable as s
using(empid);

-- left join personnel and stocktable tables
select *
from personnel as p
left join stocktable as s
using(empid);

-- right join personnel and stocktable tables
select *
from personnel as p
right join stocktable as s
using(empid);

-- outer join personnel and stocktable tables
select * 
from personnel as p
left join stocktable as s
using(empid)
union all
select *
from personnel as p
right join stocktable as s
using(empid)
where p.empid is null;

-- left excluding join of personnel and stocktable tables
select *
from personnel as p
left join stocktable as s
using(empid)
where s.empid is null;

-- or

select *
from personnel
where empid not in (select empid from stocktable);

-- right excluding join of personnel and stocktable tables
select *
from personnel as p
right join stocktable as s
using(empid)
where p.empid is null;

-- or

select *
from stocktable
where empid not in (select empid from personnel);

-- outer excluding join of personnel and stocktable tables
select *
from personnel as p
left join stocktable as s
using(empid)
where s.empid is null
union all
select *
from personnel as p
right join stocktable as s
using(empid)
where p.empid is null;

-- fetch all employees whose salary are above average from the worker table
select *
from worker
where salary>(select avg(salary) from worker);

-- fetch the name and department of all employees who are manager
select *
from worker
where worker_id in (select worker_ref_id from title where worker_title="manager");

-- or

select w.first_name, w.last_name, w.department, t.worker_title
from worker as w
inner join title as t
on worker_id=worker_ref_id
where t.worker_title="manager";

-- fetch the employee id and full name of all the employees whose manager id is 25 from the employeedetails table
select *
from employeedetails
where managerid=25;

-- fetch the different projects available in the employeesalary table
select distinct(project)
from employeesalary;

-- fetch the count of employees working in project 'p1'
select project, count(empid) as emploCount
from employeesalary
where project="p1";

-- fetch the maximum, minimum, and average of the employees salary
select min(salary) as minSalary, avg(salary) as avgSalary, max(salary) as maxSalary
from employeesalary;

-- fetch the employee id, name, and salary where salary is in the range of 9000 and 15000
select empid, fullname, salary
from employeedetails
inner join employeesalary
using(empid)
where salary>9000 and salary<15000;

-- fetch employee id, name, and salary of employees who live in Toronto and work with a manager with id of 30
select empid, fullname, city, managerid, salary
from employeedetails
inner join employeesalary
using(empid)
where city="Toronto" and managerId=30;

-- fetch employee id, name, and project of employees who work on projects other than p1
select empid, fullname, project
from employeedetails
inner join employeesalary
using(empid)
where project<>"p1";

-- show the total salary of each employee adding the salary with variable
select empid, (salary+variable) as totalSalary
from employeesalary;

-- fetch the employees whose name begins with any two characters, followed by a text "hn" and ending with any sequence of characters 
select fullname
from employeedetails
where fullname like "__hn%";

-- or

select fullname
from employeedetails
where fullname like "%%hn%";

-- or

select fullname
from employeedetails
where substring(fullname,3,2)='hn';

-- fetch the names that are present in employeedetails but not in the employeesalary
select fullname
from employeedetails
where empid not in (select empid from employeesalary);

-- or

select fullname
from employeedetails
left join employeesalary as s
using(empid)
where s.empid is null;

-- or

Select fullname
from employeedetails as d
left join employeesalary as s
on d.empid=s.empid
where s.empid is null;

-- fetch employee names having a salary greater than or equal to 5000 and less than or equal to 10000
select fullname
from employeedetails
where empid in (select empid from employeesalary where salary>5000 and salary<10000);

-- or

select fullname
from employeedetails
where empid in (select empid from employeesalary where salary between 5000 and 10000);

-- or

select fullname
from employeedetails
inner join employeesalary
using(empid)
where salary between 5000 and 10000;

-- fetch all employees from employeedetail who have a salary record in employeesalary table
select fullname
from employeedetails
where empid in (select empid from employeesalary);

-- or

select fullname
from employeedetails
inner join employeesalary
using(empid);

-- find counts of projects for each employee
select fullname, count(project) as projCount
from employeedetails
inner join employeesalary as s
using(empid)
group by s.empid;

-- or

with selected as
(
select fullname, project
from employeedetails
inner join employeesalary
using(empid) 
)
select fullname, count(project)
from selected
group by fullname
order by count(project) desc;

-- or

select empid, count(empid)
from employeesalary
group by empid
order by count(empid) desc;

-- display the employees names and salaries even if the salary record is not presented in the employeesalary table (show null in those cases)
select fullname, salary
from employeedetails
left join employeesalary as s
using(empid);

-- fetch all the employees who are managers from the employeedetails table
select fullname
from employeedetails
where empid in (select managerid from employeedetails);

-- show the name of managers and the count of their employees
with selected as
(
select managerid, count(empid) as emploCount
from employeedetails
group by managerid
)
select e.empid, e.fullname, s.emploCount
from employeedetails as e
inner join selected as s
on e.empid=s.managerid;

-- fetch duplicate records from the employeedetails table if just empids are the searching key 
select e1.empid, e1.fullname
from employeedetails as e1
inner join employeedetails as e2
where e1.empid<>e2.empid and e1.fullname=e2.fullname;

-- or

select empid, fullname, count(empid) as idCount
from employeedetails
group by empid
having idCount>1;

-- or

with selected as
(
select empid, count(empid) as idCount
from employeedetails
group by empid
having idCount>1
)
select *
from employeedetails
where empid in (select empid from selected);

-- fetch duplicate records from the employeedetails table (realistic approach)
select fullname, managerid, joining_date, city, count(*) as repeatCount
from employeedetails
group by fullname, managerid, joining_date, city
having repeatCount>1;

-- or

select e1.empid, e1.fullname
from employeedetails as e1
inner join employeedetails as e2
where e1.empid<>e2.empid and e1.fullname=e2.fullname and e1.managerid=e2.managerid and e1.city=e2.city and e1.joining_date=e2.joining_date;

-- delete duplicate records from employeedetails table
select e1.empid, e1.fullname, e1.managerid, e1.city, e1.joining_date
from employeedetails as e1
inner join employeedetails as e2
where e1.empid<>e2.empid and e1.fullname=e2.fullname and e1.managerid=e2.managerid and e1.city=e2.city and e1.joining_date=e2.joining_date
union all
select e1.empid, e1.fullname, e1.managerid, e1.city, e1.joining_date
from employeedetails as e1
left join employeedetails as e2
using(empid)
where e2.empid is null;

-- the primary way to delete duplicate records from employeedetails table: using delete command
set SQL_safe_updates=0;
delete e1
from employeedetails as e1
inner join employeedetails as e2
where e1.empid<>e2.empid and e1.fullname=e2.fullname and e1.managerid=e2.managerid and e1.joining_date=e2.joining_date and e1.city=e2.city;
set SQL_safe_updates=1;

-- fetch only odd rows from the employeedetails table if we have a nice incremental feature without any exception
select *
from employeedetails
where mod(empid,2)=1;

-- fetch odd rows from the table if we don't have an incremental feature
with selected as
(
select *, row_number() over() as rowNum
from employeedetails
)
select * 
from selected
where mod(rowNum,2)=1;

-- fetch even rows from the table if we don't have an incremental feature 
with selected as
(
select *, row_number() over() as rowNum
from employeedetails
)
select * 
from selected
where mod(rowNum,2)=0;

-- select the 3rd highest salary from the employeesalary table
select *
from employeesalary
order by salary desc
limit 2,1;

-- select the 6th highest salary without limit command
with selected as
(
select *, dense_rank() over(order by salary desc) as salRank
from employeesalary
)
select * 
from selected
where salRank=6;

-- show the books table
select *
from books;

-- show the authors table
select *
from authors;

-- find top 4 authors who sold the greatest number of books, totally
with selected as
(
select author_name, book_name, sold_copies
from books as b
inner join authors as a
using(book_name)
)
select author_name, sum(sold_copies) as totalSold
from selected
group by author_name
order by totalSold desc
limit 4;

-- or

select author_name, sum(sold_copies) as totalSold
from books as b
inner join authors as a
using(book_name)
group by author_name
order by totalSold desc
limit 4;

select *
from eventlist2;

-- find users with more than 3 events
select id, count(id) as eventCount
from eventlist2
group by id
having eventCount>3;

-- find the count of users with more than 3 events
with selected as
(
select id, count(id) as eventCount
from eventlist2
group by id
having eventCount>3
)
select count(id) as usersCount
from selected;

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

-- show the applst1 table
select *
from applst1;

-- write a query to print the count of "click" in 2015 for each appId 
select appid, count(eventid) as clickCount
from applst1
where eventid="click" and year(date(timestamp))=2015
group by appid
order by appid;

-- write a query to print the count of “click”s for each app in 2015. Consider that some apps have zero count of click. So, modify the above query to show them as well.
select appid, sum(case when eventid="click" then 1 else 0 end) as clickCount
from applst1
where year(timestamp)=2015
group by appid
order by appid;

-- write a query to find the count of click and impression for all appids in 2015
select appid, sum(case when eventid='click' then 1 else 0 end) as clickCount, sum(case when eventid='impression' then 1 else 0 end) as impressionCount
from applst1
where year(timestamp)=2015
group by appid
order by appid;

-- print the count of distinct appids at 2015
select count(distinct(appid))
from applst1
where year(timestamp)=2015;

-- write a query to find the general average of count of click and count of impression for all app in 2015 
select sum(case when eventid="click" then 1 else 0 end)/count(distinct(appid)) as avgClickCount, sum(case when eventid="impression" then 1 else 0 end)/count(distinct(appid)) as avgImprCount
from applst1
where year(timestamp)=2015;

-- write a query to print the click rate for each appid in 2015
select appid, sum(case when eventid="click" then 1 else 0 end)/count(eventid) as clickRate
from applst1
where year(date(timestamp))=2015
group by appid
order by appid;

-- print the overall click rate in 2015
select sum(case when eventid="click" then 1 else 0 end)/count(eventid) as clickRate
from applst1
where year(date(timestamp))=2015;

-- show the table1 table
select *
from table1;

-- find the ratio of males and females
select sum(case when gender="female" then 1 else 0 end)/count(gender) as FemRatio, sum(case when gender="male" then 1 else 0 end)/count(gender) as MalRatio
from table1;

-- find ratio of males and females in each department
select department, sum(case when gender="female" then 1 else 0 end)/count(gender) as FemRatio, sum(case when gender="male" then 1 else 0 end)/count(gender) as MalRatio
from table1
group by department;

-- show the total_trans table
select *
from total_trans;

-- write a query to calculate the cumulative spend for each product over the time in chronological order
select productid, date, spend, sum(spend) over(partition by productid order by total_trans.date) as cumulativeSpend
from total_trans;

-- show the housetable table
select *
from housetable;

-- find top 3 zip codes by market share of house prices for any zip code with at least 2 houses
select zipcode, sum(price) as marketShare
from housetable
group by zipcode
having count(zipcode)>1
order by marketshare desc
limit 3;

-- show the trandata table
select *
from trandata;

-- write a query to get the list of customers who their earliest purchase was at least 50$
with selected as
(
select userid, spend, dense_rank() over(partition by userid order by trandate) as purOrder
from trandata
)
select userid, spend
from selected
where purOrder=1 and spend>=50;

-- or 

with selected as
(
select userid, min(date(trandate)) as firstPurchaseDate
from trandata
group by userid
)
select t.userid, t.spend
from selected as s
join trandata as t
on s.userid=t.userid and s.firstpurchasedate=t.trandate
where t.spend>=50;

-- show the cities table
select *
from cities;

-- sort the cities of each country based on their population
select dense_rank() over(partition by country order by population desc) as cityRank, country, city, population
from cities;

-- find the top 2 cities in each country based on population
with selected as
(
select dense_rank() over(partition by country order by population desc) as cityRank, country, city, population
from cities
)
select * 
from selected
where cityRank<3;

-- show the trantable
select *
from trantable;

-- for each product find how many times it is sold in year 2014
select productid, count(productid) as soldCount
from trantable
where year(trandate)=2014
group by productid
order by productid;

-- calculate the top three most sold products within each category in 2014
with selected as
(
select category, productid, count(productid) as purCount, sum(spend) as totalSpend
from trantable
where year(trandate)=2014
group by category, productid
), selected2 as
(
select *, row_number() over(partition by category order by totalSpend desc) as soldRank
from selected
)
select *
from selected2
where soldRank<4;


