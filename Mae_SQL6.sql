USE ORG;

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

