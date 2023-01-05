Select * 
From PortfolioProject..CovidDeaths
where continent is not null


--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelyhood of dying if you contract Covid

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
order by 1,2

--Looking at the total cases vs the population
--Shows what percentage of the population has gotten Covid

Select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to Population

Select  location,  
		population,		
		max(total_cases) as HighestInfectionCount,
		max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
group by location,population
order by 4 desc

--Showing countries with the highest death count per population

Select  location,  
		max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

--Let's break things down by continent

--showing continent with highest death counts

Select  continent,  
		max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--Select  location,  
--		max(cast(total_deaths as int)) as HighestDeathCount
--from PortfolioProject..CovidDeaths
--where continent is null
--group by location
--order by HighestDeathCount desc

--Global Numbers

--death Percentage per day

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
group by date
order by 1,2 desc

--total death percentage

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
---group by date
order by 1,2 desc


--Looking at total population VS Vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_total_Vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use CTE-----
with PopvsVac (continent, location, date, population, NewVaccinations, RollingPeopleVaccinated) as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_total_Vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage 
from PopvsVac

--Create temp table

Drop table if exists #PercentPopVaccinated
Create table #PercentPopVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_total_Vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage 
from #PercentPopVaccinated

--creating views for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_total_Vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null



create view DeathPercentageIfInfected as
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null


create view PopInfectedPercent as
Select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null

create View HighestInfectionRate as
Select  location,  
		population,		
		max(total_cases) as HighestInfectionCount,
		max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Canada%'
where continent is not null
group by location,population


Create view HighestDeathCountry as 
Select  location,  
		max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location

Create view HighestDeathContinent as 
Select  location,  
		max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is null 
and location <> 'World'
group by location

