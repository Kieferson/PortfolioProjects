Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4 

--Select *
--FROM PortfolioProject..CovidDeaths
--order by 3,4 

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1, 2

-- Looking at the Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Philippines'
and continent is not null
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases / population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Philippines'
WHERE continent is not null
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Philippines'
WHERE continent is not null
GROUP BY location, population
order by PercentPopulationInfected DESC

--Showing the Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Philippines'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Philippines'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Philippines'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
--WHERE location like 'Philippines'
WHERE continent is not null
GROUP BY date
order by 1, 2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3




--Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac





-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  On dea.location = vac.location
  and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations
Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
  On dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select * 
FROM PercentPopulationVaccinated