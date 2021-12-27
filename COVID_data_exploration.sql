select * from PortfolioProject ..CovidDeaths
where continent is not null
order by 3, 4


--select * from PortfolioProject ..CovidVaccinations
--order by 3, 4

-- Get the data
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject ..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- The Chances of Dying if One Contracts COVID
select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
--where location like '%kenya%'
where continent is not null
order by 1,2


-- Total Cases vs Population
-- Percentage of Population that contracted COVID
select location, date, total_cases,  population,(total_cases/population)*100 as InfectedPercentage
from PortfolioProject ..CovidDeaths
--where location like '%africa%'
where continent is not null
order by 1,2

-- checking highest infection count per population
select location, max(total_cases) as HighestInfectionCount, population, max(total_cases/population)*100 as HighestInfectedPercentage
from PortfolioProject ..CovidDeaths
--where location like '%africa%'
where continent is not null
Group by location, population
order by HighestInfectedPercentage desc


--Show the countries with the highest death count per population
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject ..CovidDeaths
--where location like '%africa%'
where continent is not null
Group by location, population
order by HighestDeathCount desc

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject ..CovidDeaths
--where location like '%africa%'
where continent is null
Group by location
order by HighestDeathCount desc

--BREAKDOWN BY CONTINENT

--Continents with the Highest Death Count
select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject ..CovidDeaths
--where location like '%africa%'
where continent is not null
Group by continent
order by HighestDeathCount desc

--GLOBL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
--where location like '%kenya%'
where continent is not null
Group by date
order by 1,2

--Total Cases and Deaths in the World
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
--where location like '%kenya%'
where continent is not null
--Group by date
order by 1,2

--checking the COVID vaccinations table
select * 
from PortfolioProject ..CovidVaccinations

--Join COVID Vaccinations and COVID Death Tables
--Looking at Total Vaccination vs Population

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric, 
	RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
-- where dea.continent is not null
	--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




--CREATE VIEW
--Create view to store data for later visualisation


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as
RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3


Create View TotalCasesandDeaths as
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject ..CovidDeaths
--where location like '%kenya%'
where continent is not null
--Group by date
--order by 1,2

select *
from PercentPopulationVaccinated

select * 
from TotalCasesandDeaths


create view DeathCount as
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject ..CovidDeaths
--where location like '%africa%'
where continent is null
Group by location, population


select * 
from DeathCount