/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

Select * 
From PortfolioProject..CovidVaccinations
Order By 3,4

-- Selct Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where Location LIKE '%states%'
AND continent is not null
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentageInfectedPopulation
From PortfolioProject..CovidDeaths
Where Location LIKE '%states%'
And continent is not null
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select Location, population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, Population
Order By TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC

--GLOBAL NUMBERS

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast 
(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location LIKE '%states%'
Where continent is not null
Group By Date
Order By 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Where continent is null
AND location not in ('World', 'European Union', 'International')
Group by location
Order By TotalDeathCount DESC



Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast 
(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location LIKE '%states%'
Where continent is not null
--Group By Date
Order By 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,dea.date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac(Continent, Location, Date, Population, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, RollingPeopleVaccinated
Sum(CONVERT(int, vac.new_vaccinations)) OVER Partition by dea.location Order By dea.location,dea.date
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,dea.date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,dea.date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3


Select * 
From PercentPopulationVaccinated


-- TABLEAU QUERIES 

--QUERY 1 

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast 
(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location LIKE '%states%'
Where continent is not null
--Group By Date
Order By 1,2


--QUERY 2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Where continent is null
AND location not in ('World', 'European Union', 'International')
Group by location
Order By TotalDeathCount DESC


-- QUERY 3


Select Location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC


--QUERY 4

Select Location, Population, date, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where continent is not null
Group By Location, Population, date
Order By PercentPopulationInfected DESC

