USE ORG;

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
