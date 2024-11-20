create database motors;
use motors;
show tables;

select * from dim_dates;

select * from electric_vehicle_sales_by_maker;

select * from electric_vehicle_sales_by_states;
alter table dim_dates rename column ï»¿date  to dates;
alter table electric_vehicle_sales_by_maker rename column ï»¿date  to dates;
alter table electric_vehicle_sales_by_states rename column ï»¿date to dates;

-- TASK1  
select maker,fiscal_year,sum(ev.electric_vehicles_sold)as total_ev_sold from dim_dates
 inner join electric_vehicle_sales_by_maker as ev using(dates)
group by maker,fiscal_year having fiscal_year='2023' order by total_ev_sold desc limit 3;

select maker,fiscal_year,sum(ev.electric_vehicles_sold)as total_ev_sold from dim_dates inner join electric_vehicle_sales_by_maker as ev using(dates)
 group by maker,fiscal_year having fiscal_year='2024' order by total_ev_sold desc limit 3;
 
 with cte as (select ev.maker,fiscal_year,sum(electric_vehicles_sold) as total_ev_sales,dense_rank()over(partition by fiscal_year order by sum(ev.electric_vehicles_sold)asc)as ranking
 from dim_dates inner join electric_vehicle_sales_by_maker as ev using(dates) where vehicle_category='2-wheelers' and fiscal_year in ('2024') group by maker,fiscal_year order by fiscal_year)
 select maker,fiscal_year,total_ev_sales from cte where ranking<=3;
 select maker,fiscal_year,sum(electric_vehicles_sold) as total_ev_sales from dim_dates inner join electric_vehicle_sales_by_maker as ev 
 using(dates) where vehicle_category='2-wheelers' and fiscal_year='2023' group by maker,fiscal_year order by total_ev_sales limit 3;
 use motors;
with cte as (select ev.maker,fiscal_year,sum(electric_vehicles_sold) as total_ev_sales,dense_rank()over(partition by fiscal_year order by sum(ev.electric_vehicles_sold)asc)as ranking
 from dim_dates inner join electric_vehicle_sales_by_maker as ev using(dates) where vehicle_category='2-wheelers' and fiscal_year in ('2023') group by maker,fiscal_year order by fiscal_year)
 select maker,fiscal_year,total_ev_sales from cte where ranking<=3;


 select maker,fiscal_year,sum(electric_vehicles_sold) as total_ev_sales from dim_dates inner join electric_vehicle_sales_by_maker as ev 
 using(dates) where vehicle_category='2-wheelers' and fiscal_year='2023' group by maker,fiscal_year order by total_ev_sales limit 3;
  select maker,fiscal_year,sum(electric_vehicles_sold) as total_ev_sales from dim_date inner join electric_vehicle_sales_by_makers as ev 
 using(dates) where vehicle_category='2-wheelers' and fiscal_year='2024' group by maker,fiscal_year order by total_ev_sales limit 3;
 
-- Task2 --
 select ev.state,(sum(ev.electric_vehicles_sold)/sum(ev.total_vehicles_sold))*100 as penetration_rate from electric_vehicle_sales_by_states as ev 
 inner join dim_dates using(dates) where vehicle_category='2-wheelers' and fiscal_year='2024'
 group by state order by penetration_rate  desc limit 5;
 
  select ev.state,(sum(ev.electric_vehicles_sold)/sum(ev.total_vehicles_sold))*100 as penetration_rate from electric_vehicle_sales_by_states as ev 
 inner join dim_dates using(dates) where vehicle_category='4-wheelers' and fiscal_year='2024'
 group by state order by penetration_rate  desc limit 5;
 
 -- TASK 3--
 select ev.state,sum(case when fiscal_year=2022 then  electric_vehicles_sold  else 0 end) as sales2022,
 sum(case when fiscal_year='2024' then electric_vehicles_sold else 0 end)as sales2023 from electric_vehicle_sales_by_states ev inner join dim_dates using(dates)
 where fiscal_year in('2022','2024')group by state order by state;
 
 
 --  TASK4-- 
 with top5maker as(select  maker from electric_vehicle_sales_by_maker  inner join dim_dates using(dates) where vehicle_category='4-wheelers'  group by maker order by sum(electric_vehicles_sold) desc limit 5)
 select maker,fiscal_year,quarter,sum(electric_vehicles_sold)as total_sales from electric_vehicle_sales_by_maker ev inner join dim_dates using(dates)
 where vehicle_category='4-wheelers' and maker in (select maker from top5maker) group by maker,fiscal_year,quarter order by maker,fiscal_year,quarter;

--  TASK 5
select  state,round((sum(electric_vehicles_sold)/sum(total_vehicles_sold))*100,1) as penetration_rate from electric_vehicle_sales_by_states ev  inner join dim_dates using(dates) where state in ('delhi','karnataka') and fiscal_year='2024'group by state order by penetration_rate;
select state,sum(electric_vehicles_sold)as total_sales from electric_vehicle_sales_by_state inner join dim_date using(dates) where state in('delhi','karnataka') and fiscal_year='2024' group by state order by total_sales desc ;

-- TASK 6--
with cte as(select maker,sum(electric_vehicles_sold)as vehicle_sold from electric_vehicle_sales_by_maker ev inner join dim_dates using(dates)
where vehicle_category='4-wheelers'group by maker order by vehicle_sold desc limit 5)
select maker,power((sum(case when fiscal_year='2024' then electric_vehicles_sold else 0 end)/sum(case when fiscal_year='2022' then  electric_vehicles_sold else 0 end)),0.5)-1 as cagr
from electric_vehicle_sales_by_maker inner join dim_dates using(dates) where vehicle_category='4-wheelers' 
and maker in ( select maker from cte)
group by maker order by cagr desc limit 5;

-- TASK 7--  
  with cte as(select state,sum(electric_vehicles_sold)as ev_sold from dim_dates inner join electric_vehicle_sales_by_states using(dates) where vehicle_category='4-wheelers'  group by state order by ev_sold desc limit 10)
  select state,power((sum(case when fiscal_year='2024' then electric_vehicles_sold else 0 end)/sum(case when fiscal_year='2022' then electric_vehicles_sold else 0 end)),0.5)-1 as cagr
  from electric_vehicle_sales_by_states  inner join dim_dates using(dates) where state in (select state from cte) group by state order by cagr desc limit 10;
  select * from  dim_date;
-- TASK 8--
select extract(month from dates)as months,monthname(dates)as monthname,sum(electric_vehicles_sold)as ev_sold from dim_dates
 inner join electric_vehicle_sales_by_maker using(dates) group by months,monthname order by months,monthname desc ;
 
 -- TASK 9--
 with peneteration_rate as(select state,round(sum(electric_vehicles_sold)/sum(total_vehicles_sold)*100,2)as peneteration_rate from dim_dates inner join electric_vehicle_sales_by_states using(dates)
 group by state order by peneteration_rate desc limit 10),
  cagr as (select state,power((sum(case when fiscal_year='2024' then electric_vehicles_sold else 0 end)/sum(case when fiscal_year='2022' then electric_vehicles_sold else 0 end)),0.5)-1 as cagr
 from electric_vehicle_sales_by_states inner join dim_dates using(dates) where state in (select state from peneteration_rate) group by state order by cagr desc limit 10),
 sales as(select state,sum(electric_vehicles_sold)as ev_sales_2022 from dim_dates inner join electric_vehicle_sales_by_states using(dates) where fiscal_year='2022' group by state )
 select sales.state,ev_sales_2022,cagr.cagr,round(ev_sales_2022*power(1+cagr,8),2)as projection_2030 from sales join cagr on sales.state=cagr.state group by state order by projection_2030 desc ;
 
 -- TASK 10-- 
 select vehicle_category,fiscal_year ,case when vehicle_category='2-wheelers' then sum(electric_vehicles_sold*85000) else sum(electric_vehicles_sold*1500000) end as revenue
 from electric_vehicle_sales_by_states inner join dim_dates using(dates) group by vehicle_category,fiscal_year order by vehicle_category,fiscal_year;
  

