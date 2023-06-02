select * from Portfolio..['coviddeaths$'];

--- global numbers

select date, total_cases, total_deaths, 
(cast(total_cases as float))/(cast(total_cases as float)) as death_per 
from Portfolio..['coviddeaths$']
where continent is not null
group by date
order by 1,2;



select * from Portfolio..['coviddeaths$'];


select * from Portfolio..['covidvacciantions$'];

--looking at Total population vs Vaccinations
 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from Portfolio..['coviddeaths$'] dea
join Portfolio..['covidvacciantions$'] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated from Portfolio..['coviddeaths$'] dea
join Portfolio..['covidvacciantions$'] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
;

--USE CTE 
with popvsvac (continent, location, date, population,new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio..['coviddeaths$'] dea
join Portfolio..['covidvacciantions$'] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from popvsvac






--temp table

drop table if exists #percentPopulationvaccinated
create table #percentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percentPopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio..['coviddeaths$'] dea
join Portfolio..['covidvacciantions$'] vac
on dea.location =vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100
from #percentPopulationvaccinated



--creating view to store data for later visualization
create view percentPopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio..['coviddeaths$'] dea
join Portfolio..['covidvacciantions$'] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select * from percentPopulationvaccinated