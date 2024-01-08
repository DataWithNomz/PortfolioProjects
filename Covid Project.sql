-- Select data we need
-- Order by 3rd col then 4th col

select Location, date, total_cases, new_cases, total_deaths, population
From ProfolioProject.dbo.CovidDeath
Order by 1,2

-- Looking at total cases vs total deaths (% Death by Covid) 
-- Float for Division 
-- % expression for any char

select Location, date, total_cases,  total_deaths,  (total_deaths  / total_cases) * 100 AS DeathPercentage
From ProfolioProject.dbo.CovidDeath
where location like '%states%'
Order by DeathPercentage DESC

-- Total cases vs Population

select Location, date, total_cases,  total_deaths,  (total_cases  /  population) * 100 AS CovidPercentage
From ProfolioProject.dbo.CovidDeath
where location like '%States%'
Order by CovidPercentage DESC

-- Country with Highest infection rate compared to population
-- All select coloumns must be in GROUP BY clause

Select location, population,  max(total_cases) AS HighestInfectionCount,  max((total_cases  /  population)) * 100 AS infectionPercentage
From ProfolioProject.dbo.CovidDeath
Group by location, population
order by 4 DESC

-- Country with Highest date rate compared to population

Select location, max(total_deaths) AS HighestDeathCount,  max((total_deaths  /  population)) * 100 AS DeathPercentage
From ProfolioProject.dbo.CovidDeath
Where continent is not null
Group by location
order by 2 DESC

-- Country with Highest date rate compared to continent

Select continent, max(total_deaths) AS HighestDeathCount,  max((total_deaths  /  population)) * 100 AS DeathPercentage
From ProfolioProject.dbo.CovidDeath
Where continent is not null
Group by continent
order by 2 DESC

Select continent,  max((total_deaths  /  population)) * 100 AS DeathPercentage
From ProfolioProject.dbo.CovidDeath
Where continent is not null
Group by continent
order by 2 DESC

-- Global Numbers
-- Had to change data type to float

select SUM(new_cases) AS total_new_cases,
 SUM(new_deaths) AS total_new_deaths,  
  CAST(SUM(new_deaths) AS FLOAT) / CAST(SUM(new_cases) AS FLOAT) * 100 
From ProfolioProject.dbo.CovidDeath
Where continent IS NOT NULL
order by 1,2

-- Vaccination table
-- Joined both table same order (Location and Date)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from ProfolioProject..CovidDeath dea
Join ProfolioProject..CovidVac vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent IS NOT NULL
order by 3 

-- Rolling count for Vaccination
-- Resets count when a new location is found (Adds  new vaccination each day)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) AS VacRollingCount
from ProfolioProject..CovidDeath dea
Join ProfolioProject..CovidVac vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent IS NOT NULL
order by 2, 3 

-- Total population that is Vaccinated

With popVSvac (Continent, location, Date, Population, new_vaccinations, VacRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) AS VacRollingCount
from ProfolioProject..CovidDeath dea
Join ProfolioProject..CovidVac vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent IS NOT NULL
--order by 2, 3 
)
Select *, (CAST(VacRollingCount AS FLOAT)/CAST(Population AS FLOAT))*100 As PercentageVac
From popVSvac


-- TEMP TABLE

Drop Table if exists PercentPopulationVaccination#
CREATE TABLE PercentPopulationVaccination#
(
    Continent nvarchar(255),
    Location nvarchar(255),
    date datetime,
    Population numeric,
    New_vaccinations numeric,
    VacRollingCount numeric
)


INSERT INTO PercentPopulationVaccination#
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) AS VacRollingCount
from ProfolioProject..CovidDeath dea
Join ProfolioProject..CovidVac vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent IS NOT NULL
--order by 2, 3 

Select *, (CAST(VacRollingCount AS FLOAT)/CAST(population AS FLOAT))*100 As PercentageVac
From PercentPopulationVaccination#


-- Creating permanent view to store for later visulisation

create view PercentPopulationVaccinationv AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) AS VacRollingCount
from ProfolioProject..CovidDeath dea
Join ProfolioProject..CovidVac vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent IS NOT NULL

