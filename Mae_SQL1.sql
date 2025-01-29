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


