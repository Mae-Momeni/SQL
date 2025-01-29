USE ORG;

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


