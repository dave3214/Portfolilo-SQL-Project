select * from 
dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from 
--dbo.CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2


---- total cases vs total dealths

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DealthPercentage
from dbo.CovidDeaths
where location like '%United Kingdom%'
order by 1,2

---- total cases vs population

select location, date, population, total_cases,  (total_cases/population)*100 as PopulationPercentage
from dbo.CovidDeaths
---where location like '%United Kingdom%'
order by 1,2

-----countries with highest infectin rates vs population

select location, population, MAX(total_cases) as HighestInfectionCountries,  MAX((total_cases/population))*100 as PopulationInfectedPercentage
from dbo.CovidDeaths
----where location like '%United Kingdom%'
Group by location, population
order by PopulationInfectedPercentage desc

---Countries with highest dealth count vs population

select location, MAX(cast(total_deaths as int)) as TotalDealthCount
from dbo.CovidDeaths
----where location like '%United Kingdom%'
where continent is not null
Group by location
order by TotalDealthCount desc


---- by continent with highest dealth count

select continent, MAX(cast(total_deaths as int)) as TotalDealthCount
from dbo.CovidDeaths
----where location like '%United Kingdom%'
where continent is not null
Group by continent
order by TotalDealthCount desc

----calculate across the entire world

select  SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from dbo.CovidDeaths 
---where location like '%United Kingdom%'
where continent is not null
---group by date
order by 1,2

---- to join the two tables together and also looking at TotalPopulation vs TotalVaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
   
   With PopvsVac (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)

as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)

Select * , (RollingPeopleVaccinated/population)*100 
from PopvsVac

---Temp Table

Drop Table if exists PercentPopulationVacinated
create Table PercentPopulationVacinated
(
contient nvarchar (225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into PercentPopulationVacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
---order by 2,3

Select * , (RollingPeopleVaccinated/population)*100 
from PercentPopulationVacinated


----creating view to store data

create view PercentPopulationVacinatedd as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
----(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3

 
select * from PercentPopulationVacinatedd
