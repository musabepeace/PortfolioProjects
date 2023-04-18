/* 
COVID19 DATA EXPLORATION

Skills Used: JOins, CTE's Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM Project..COVIDDeaths
WHERE continent is not null
ORDER BY 3,4

--Starting Data

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM Project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Cases vs Total Deaths
	--Shows the likelihood of one dying if they contract covid in their country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths
WHERE continent is not null
	and location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population
	--Shows what percentage of popualtion has COVID

SELECT Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM Project..CovidDeaths
WHERE continent is not null
	and location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population
	--Shows the countries where one is most likely to contract COVID

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- Death Count by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Looking at Population vs Total Vaccinations
	--Shows total people vaccinated in a location by day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as numeric)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


--Using CTE to perform calculation on partition by from previous query  

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPoepleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as numeric)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPoepleVaccinated/Population)*100
FROM PopvsVac


-- Using TEMP TABLE to perform calculation on partition by from previous query  

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locations nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as numeric)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating View to Store Data for Later Visualizations 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as numeric)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3








