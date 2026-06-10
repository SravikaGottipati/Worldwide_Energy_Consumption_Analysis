-- Database Creation

create database energy_db;
use energy_db;

-- Data Exploring

show tables;
select * from country limit 5;
select * from country where Country="India";
select * from population;
select * from emission;
select * from production;
select * from gdp;
select * from consumption;
describe country;
describe consumption;
describe emission;
describe gdp;
describe population;
describe production;

-- Data Cleaning and preparation

alter table consumption 
rename column country to Country;

alter table emission
rename column country to Country;

alter table population
rename column countries to Country;

alter table production
rename column country to Country;

alter table emission
rename column `energy type` to energytype;

alter table gdp
rename column `Value` to gdp_value;

alter table population
rename column `Value` to pop_value;

alter table emission
rename column `per capita emission` to per_capita_emission;

alter table country
modify Country varchar(100);

alter table consumption
modify Country varchar(100);

alter table emission
modify Country varchar(100);

alter table gdp
modify Country  varchar(100);

alter table population
modify Country varchar(100);

alter table production
modify Country varchar(100);

alter table country
add primary key(Country);

-- Establishing the relationship between the tables

alter table consumption
add constraint fk_consumption_country
foreign key(Country)
references country(Country);

alter table emission
add constraint fk_emission_country
foreign key (Country)
references country(Country);

alter table gdp
add constraint fk_gdp_country
foreign key (Country)
references country(Country);

alter table population
add constraint fk_population_country
foreign key (Country)
references country(Country);

alter table production
add constraint fk_production_country
foreign key (Country)
references country(Country);


-- question 1 
-- What is the total emission per country for the most recent year available?

select Country,sum(emission) as total_emission 
from emission 
where year=(select max(year) from emission)
group by Country;


-- question 2
-- What are the top 5 countries by GDP in the most recent year?

select Country,gdp_value
from gdp 
where year=(select max(year) from gdp)
order by gdp_value desc limit 5;


-- question 3
-- Compare energy production and consumption by country and year. 

select production.Country,production.year,sum(production.production) as total_production,sum(consumption.consumption) as total_consumption
from production
inner join consumption
on production.Country=consumption.Country and production.year=consumption.year
group by production.Country,production.year
order by Country,year;

-- question 4
-- Which energy types contribute most to emissions across all countries?

select energytype,sum(emission) as total from emission
group by energytype
order by total desc;


-- question 5
-- How have global emissions changed year over year?

select year,sum(emission) as total_emissions from emission
group by year
order by year;


-- question 6
-- What is the trend in GDP for each country over the given years?

select Country,year,gdp_value
from gdp
order by Country,year;


-- question 7
-- How has population growth affected total emissions in each country?

select population.Country,population.year,sum(population.pop_value) as total_population,sum(emission.emission) as total_emissions
from population
inner join emission
on population.Country=emission.Country and population.year=emission.year
group by Country,year
order by Country,total_population;


-- question 8
-- Has energy consumption increased or decreased over the years for major economies?

select Country,year,sum(consumption)
from consumption
group by Country,year
order by Country,year;


-- question 9
-- What is the average yearly change in emissions per capita for each country?

select Country,avg(year_change) as avg_yearly_change 
from (select Country,year,per_capita_emission,per_capita_emission-LAG(per_capita_emission) over (partition by Country order by year) as year_change
from emission) as temp
group by Country;


-- question 10
-- What is the emission-to-GDP ratio for each country by year?

select emission.Country,sum(emission.emission)/sum(gdp.gdp_value) as ratio,emission.year
from emission
inner join gdp
on emission.Country=gdp.Country and emission.year=gdp.year
group by Country,year
order by Country,year;


-- question 11
-- What is the energy consumption per capita for each country over the last decade?

select consumption.Country,consumption.year,consumption.consumption/population.pop_value as per_capita_comsumption
from consumption 
inner join population
on consumption.Country=population.Country and consumption.year=population.year
where consumption.year=(select max(consumption.year)-10 from consumption);


-- question 12
-- How does energy production per capita vary across countries?

select production.Country,sum(production.production/population.pop_value) as per_capita_production
from production
inner join population
on production.Country=population.Country
group by Country
order by production.Country;


-- question 13
-- Which countries have the highest energy consumption relative to GDP?

select consumption.Country,sum(consumption.consumption/gdp.gdp_value) as ratio
from consumption
inner join gdp
on consumption.Country=gdp.Country
group by Country
order by ratio desc;


-- question 14
-- What is the correlation between GDP growth and energy production growth?

select Country,avg(prod_growth) as production_growth,avg(gdp_growth) as gdp_growth
from
(select production.Country,production.production-LAG(production.production) over (partition by Country order by production.year) as prod_growth,gdp.gdp_value-LAG(gdp.gdp_value) over (partition by Country order by gdp.year) as gdp_growth
from production
inner join gdp
on production.Country=gdp.Country and production.year=gdp.year) as temp
group by Country;


-- question 15
-- What are the top 10 countries by population and how do their emissions compare?

select population.Country,max(population.pop_value) as total_pop,sum(emission.emission) as emission_value
from population
inner join emission
on population.Country=emission.Country 
group by population.Country
order by total_pop desc
limit 10;


-- question 17
-- What is the global share (%) of emissions by country?

select Country,sum(emission) as country_emission,sum(emission)/(select sum(emission) from emission) * 100 as global_percentage
from emission
group by Country;


-- question 18
-- What is the global average GDP, emission, and population by year?

select gdp.year, avg(gdp.gdp_value) as avg_gdp, avg(emission.emission) as avg_emission, avg(population.pop_value) as  avg_population
from gdp 
inner join emission 
on gdp.Country = emission.Country and gdp.year = emission.year
join population 
on gdp.Country = population.Country and gdp.year = population.year
group by gdp.year
order by gdp.year;









