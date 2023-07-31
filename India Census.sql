
----Exploratory Data Analysis----

-- Looking for Duplicates in the datasets

with DupCTE as(
select * ,ROW_NUMBER() over (partition by [District],[State] order by [state]) as [No.] from Census1
)
delete from DupCTE
where [No.] > 1

--Q1: What are the total no. of rows in both data

select count(*) from Census1

select count(*) from Census2

--Q2: Write a query to generate Data for only 2 States?

select state,District,Growth,Sex_Ratio,Literacy from Census1
where State in ('Gujarat','Maharashtra')
order by 1

select state,District,Area_km2,Population from Census2
where State in ('Gujarat','Maharashtra')
order by 1

--Q3: Write a query to know the total population of india

select SUM(population) as [Population] from Census2

--Q4: Write a query to know the total population per state of india

select state,SUM(population) as [Population] from Census2
group by State
order by 2 desc

select * from Census1
where district = 'Daman'

select * from Census2
where State = '#N/A'

select * from Census2
order by 2

select * from Census1
order by 2

--filling up some null values in the Census2 data

update Census2
set State = 'Andaman And Nicobar Islands'
where District = 'North & Middle Andaman'

-- Q5 : Write a Query Which shows the average growth of data

select round(AVG(growth),4)*100 as [Avg Growth] from Census1


-- Q6 : Write a Query Which shows the average Growth Per State

select state,round(AVG(growth),4)*100 as [Avg Growth]  from Census1
group by State
order by 2 desc

-- Q6 : Write a Query Which shows the average sex ratio Per State

select state,round(AVG(Sex_Ratio),0) as [Avg Sex Ratio]  from Census1
group by State
order by 2 desc

-- Q6 : Write a Query Which shows the average literay rate Per State

select state,round(AVG(Literacy),2) as [Avg Literay Rate]  from Census1
group by State
order by 2 desc

-- Q6 : Write a Query Which shows the average literay rate in Gujarat State
select district,state,round(AVG(Literacy),2) as [Avg Literay Rate]  from Census1
where State = 'Gujarat'
group by State,District
order by 3 desc

-- Q7 Write a Query Which shows the state where average literay rate >90 
select state,round(AVG(Literacy),2) as [Avg Literay Rate]  from Census1
group by State
having AVG(literacy)>90
order by 2 desc

--Q8 Top 3 States having highest growth rate

select top 3 state,round(AVG(growth),4)*100 as [Avg Growth] from Census1
group by State
order by 2 desc

--Q9 Top 3 States having lowest sex ratio

select top 3 state,round(AVG(Sex_Ratio),0) as [Avg Sex Ratio] from Census1
group by State
order by 2


--Q10 Top 3 States having highest literacy rate,growth rate and sex ratio

select state,round(AVG(growth),4)*100 as [Avg Growth],round(AVG(Literacy),2) as [Avg Literay Rate],round(AVG(Sex_Ratio),0) as [Avg Sex Ratio]  from Census1
group by State
order by 2 desc,3 desc,4 desc


--Q11 Combine top 3 and bottom 3 States in terms of avg. literacy rate.

drop table if exists #Top3
create table #Top3
( state nvarchar(255),
  [Avg Literacy] float	
  )

 insert into #Top3
 select top 3 state,round(AVG(Literacy),2) as [Avg Literay Rate]from census1
 group by state
 order by 2 desc

drop table if exists #Bot3
create table #Bot3
( state nvarchar(255),
  [Avg Literacy] float	
  )

 insert into #Bot3
 select top 3 state,round(AVG(Literacy),2) as [Avg Literay Rate]from census1
 group by state
 order by 2 


 select * from #Top3
 union
 select * from #Bot3
 order by 2 desc

 --Q12 : Write a query which filter data by the state starting with letter A

 select distinct(state) from Census1
 where state like 'A%'

 select distinct(state) from Census1
 where state like 'A%' or state like 'B%'

--Q13 : Write a query which filter data by the state starting with letter A and ending with d

 select distinct(state) from Census1
 where state like 'A%m'


 select * from Census1
 order by 2
 select * from Census2
 order by 2


 --Q14 : What are the total number of males and total number of females

 -- females/males=sex ratio
 -- males + females = Population
 -- males = Population - females
 -- males = Population - (sex ratio * males)
 -- Population = males + (sex ratio * males)
 -- Population = males(1 + sex ratio)
 -- males = Population / (1 + sex ratio) --  for males
 -- females = Population - males
 -- females = Population - population/(1+ sex ratio) --  for females

 select ce.State,ce.District,ce.Sex_Ratio,ca.Population,round((ca.Population/(1 + (ce.Sex_Ratio/1000))),0) as Males,(ca.Population - round((ca.population/(1+ (ce.Sex_Ratio/1000))),0)) as females from Census1 ce
 left join Census2 ca
 on ce.District=ca.District

 select d.state as [State],sum(d.[Males]) as [Males] ,sum(d.[Females]) as [Females] from( select ce.State,sum(round((ca.Population/(1 + (ce.Sex_Ratio/1000))),0)) as Males,sum((ca.Population - round((ca.population/(1+ (ce.Sex_Ratio/1000))),0))) as Females from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State
 ) d
 group by d.State

-- Q 14 : What number of people are literrate
--Literacy = (Total Literate People / Population) * 100

 select ce.District,ce.State,sum(round((ca.Population/(1 + (ce.Sex_Ratio/1000))),0)) as Males,sum((ca.Population - round((ca.population/(1+ (ce.Sex_Ratio/1000))),0))) as females,
 round(sum(((ce.Literacy * ca.Population)/100)),0) as [Total Literate People],(ca.Population - round(sum(((ce.Literacy * ca.Population)/100)),0)) as [Illeterate People] ,ce.Literacy Literacy from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State,ce.Literacy,ca.Population,ce.District
 order by 7 desc

 select d.state as [State],sum(d.[Total Literate People]) as [Total Literate People] ,sum(d.[Illeterate People]) as [Illeterate People] from(
 select ce.State,sum(round((ca.Population/(1 + (ce.Sex_Ratio/1000))),0)) as Males,sum((ca.Population - round((ca.population/(1+ (ce.Sex_Ratio/1000))),0))) as females,
 round(sum(((ce.Literacy * ca.Population)/100)),0) as [Total Literate People],(ca.Population - round(sum(((ce.Literacy * ca.Population)/100)),0)) as [Illeterate People] ,ce.Literacy Literacy from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State,ce.Literacy,ca.Population
 ) d
 group by d.State

-- Q 15 What was the population in the previous year

-- Population Previous year + growth(Population Previous Year) = Population Current year
-- Population Previuos Year = Population Current Year / (1 + growth)

select ce.District,ce.State, round(sum((ca.Population / (1+ce.Growth))),0) as [Population 2010],ca.Population as [Population 2011],ce.Growth from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State,ca.Population ,ce.district,ce.Growth


 select d.state as [State],sum(d.[Population 2010]) as [Population 2010],sum(d.[Population 2011]) as [Population 2011]  from (select ce.District,ce.State, round(sum((ca.Population / (1+ce.Growth))),0) as [Population 2010],ca.Population as [Population 2011],ce.Growth from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State,ca.Population ,ce.district,ce.Growth
 ) d
 group by d.State


-- Q 16 What was the total population of india in previuos year comapre to this year

select sum(d.[Population 2010]) as [Population 2010],sum(d.[Population 2011]) as [Population 2011] from (
 select ce.District,ce.State, round(sum((ca.Population / (1+ce.Growth))),0) as [Population 2010],ca.Population as [Population 2011],ce.Growth from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State,ca.Population ,ce.district,ce.Growth
 ) d

 
 -- Q 17 What is the total area of india and how is the area has reduced as the population have grown

 select round(g.[Total Area]/g.[Population 2010],4) as [Area in Population 2010],round(g.[Total Area]/g.[Population 2011],4) as [Area in Population 2011] from
( select c.*,e.[Total Area] from(
select '1' as [Key], a.* from (select sum(d.[Population 2010]) as [Population 2010],sum(d.[Population 2011]) as [Population 2011] from (
 select ce.District,ce.State, round(sum((ca.Population / (1+ce.Growth))),0) as [Population 2010],ca.Population as [Population 2011],ce.Growth from Census1 ce
 left join Census2 ca
 on ce.District=ca.District
 group by ce.State,ca.Population ,ce.district,ce.Growth
 ) d
 ) a)c
 inner join 
 (select '1' as [Key],b.* from(
 select sum(Area_km2) as [Total Area] from Census2
 ) b)e
 on c.[Key] = e.[Key]
 ) g

 -- Q 18 Which are the top 3 districts from each state having hihest literacy rate

 with LiteracyRank as(
 select *,RANK() over (partition by [State] order by [Literacy] desc) as [Rank]  from Census1
 )
 select District,[State],Literacy,[Rank] from LiteracyRank
 where [Rank]<4
