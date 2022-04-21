USE ORG;

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


