use India_census

select * from dbo.Dataset1
select * from dbo.Dataset2

delete from Dataset1
where state='state'


--number of rows into the datasets

select COUNT(*) from Dataset1
select COUNT(*) from Dataset2

-- dataset for Jharkhan & Bihar

select * from Dataset1
where State in ('Jharkhan','Bihar')

--Total Population
select sum(Dataset2.Population) as Total_Population
from dbo.Dataset2


select * from dbo.Dataset1
where [Sex_Ratio] like '%[@,#,$,%,*]%'

-- Change Type of column

-- For Col Growth
update dbo.Dataset1
set [Growth]=case 
when
ISNUMERIC([Growth])=1
then
CONVERT(decimal(10,4),[Growth])
else 0 end
from dbo.Dataset1

alter table Dataset1
alter column Growth float;

-- For ColSex ration
alter table Dataset1
alter column Sex_Ratio float

update dbo.Dataset1
set [Sex_Ratio]=case 
when
ISNUMERIC([Sex_Ratio])=1
then
CONVERT(decimal(10,2),[Sex_Ratio])
else 0 end
from dbo.Dataset1

alter table Dataset1
alter column Sex_Ratio float;

-- For Literacy
update dbo.Dataset1
set [Literacy]=case 
when
ISNUMERIC([Literacy])=1
then
CONVERT(decimal(10,2),[Literacy])
else 0 end
from dbo.Dataset1

alter table Dataset1
alter column Literacy float;



--Avg Growth of india
select round(avg(Dataset1.Growth)*100,2) as Avg_Growth_Per
from dbo.Dataset1

-- Avg Growth_State wise
select State, round(AVG(Growth)*100,2) as Avg_Growth 
from dbo.Dataset1
group by State
order by Avg_Growth desc

-- Avg Sex ratio
select State, round(AVG(Sex_Ratio),0) as Avg_Sex_Ratio
from dbo.Dataset1
group by State
order by Avg_Sex_ratio desc

--Avg Literacy Ration >90
select State,round(avg(Literacy),2) as Avg_Literacy
from Dataset1
group by State
having avg(Literacy) >90
order by Avg_Literacy desc


--Top 3 States for Highest Growth Rate

select top 3 State,round(avg(Growth)*100,2) as Growth_rate
from
Dataset1
group by State
Order by Growth_rate desc


--Bottom 3 States for Sex ratio

select top 3 State,round(avg(Sex_Ratio),0) as Sex_ratio
from
Dataset1
group by State
Order by Sex_Ratio

-- Displying Top and Bottom 3 states in literacy State

--Top
drop table if exists #topstates
create table #topstates(
state varchar(50),
Lit_per float
)

insert into #topstates
select State,round(avg(Literacy),2) as Lit_rate
from
Dataset1
group by State
Order by Lit_rate desc;

select top 3 * from #topstates
order by Lit_per desc;


-- bottom
drop table if exists #bottomstates
create table #bottomstates(
state varchar(50),
Lit_per float
)

insert into #bottomstates
select State,round(avg(Literacy),2) as Lit_rate
from
Dataset1
group by State
Order by Lit_rate;

--Union opereator
select * from(
select top 3 * from #bottomstates
order by Lit_per) as a 

union

select * from(
select top 3 * from #topstates
order by Lit_per desc) as b;

--State Start with Letter A or B

select distinct state from Dataset1
where State like 'a%' or State like 'b%'


--joining both Table || Number of males and Females

--sex_ration = Female/Male
--Population = Female + male=Female+Female*Sex_ratio=female(1+sex_ratio)
--Female = Population /(1+Sex_ratio)
--male=Population - Population/(1+sex_ratio)


select d.[State ],sum(d.Population) as Total_pop,sum(d.male)as male_pop,sum(d.Female) as female_pop
from
(select *,round(t3.Population/(1+t3.ratio),0) as Male,
round((t3.Population*t3.ratio)/(1+t3.ratio),0) as Female
from (
select t1.District, t1.[State ],t1.Sex_Ratio/1000 as ratio,t2.Population
from
Dbo.Dataset1 as t1
inner join
dbo.Dataset2 as t2
on
t1.District=t2.District) as t3) as d
group by d.[State ]
order by sum(d.population) desc

--Literacy Rate State wise

select e.*,round((e.pop*e.lit)/100,0) as Literate_Persons,round((e.pop*(100-e.Lit))/100,0) as Iliterate_Persons
from 
(select d.[State ],round(avg(d.Lit_ratio),2) as Lit,sum(d.population) as pop
from
(select t1.District, t1.[State ],t1.Literacy as Lit_ratio,t2.Population
from
Dbo.Dataset1 as t1
inner join
dbo.Dataset2 as t2
on
t1.District=t2.District) as d
group by d.[State ]) as e


-- Population Density

select x.Sq_Km/x.CP as Density_Current_Census,x.Sq_Km/x.PP as Density_prev_census
from
(select q.*,r.Sq_Km from(
select '1'as Keyy,n.*
from(
select sum(l.Current_Population) as CP,sum(Previous_Population) as PP
from
(select b.[State ],sum(b.Population) as Current_Population, sum(b.Prev_Census_Population) as Previous_Population
from
(select a.*,round(a.Population/(1+a.Growth_rate),0) as Prev_Census_Population
from
(select t1.District, t1.[State ],t1.Growth as Growth_rate,t2.Population
from
Dbo.Dataset1 as t1
inner join
dbo.Dataset2 as t2
on
t1.District=t2.District) as a) as b
group by b.[State ]) as l) as n) as q
inner join
(
select '1' as keyy,m.* 
from
(
select sum(Area_km2)as Sq_Km
from
Dataset2
) as m) as r
on
q.Keyy=r.keyy) as x



--Rank

select t.* from
(select dbo.Dataset1.[State ],district,dbo.Dataset1.Literacy,rank() over (Partition by state order by literacy desc) as Ranking
from dbo.Dataset1) as t
where
t.Ranking in (1,2,3)





