/* 
   COVID 19 data exploration
*/


SELECT * 
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 3,4


 --DATA we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2


 -- Total Cases vs Total Deaths
 -- Shows the likelihood of dying if you come in contact of covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2


 -- Total Cases vs Population
 -- Shows what %age of population was infected with covid

SELECT location, date, population, total_cases, (total_deaths/population)*100 AS InfectedPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2


 -- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfected, MAX((total_deaths/population))*100 AS InfectedPercentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location, population, date
ORDER BY InfectedPercentage Desc


 -- Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount Desc


 -- Showing the CONTINENTS with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc


 -- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
             SUM(cast(new_deaths as int))/SUM(New_cases)* 100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
Where continent is not null
GROUP BY date
ORDER BY 1,2


 -- Total cases, Total deaths and DeathPercentage in the world

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
       SUM(cast(new_deaths as int))/SUM(New_cases)* 100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
Where continent is not null
--GROUP BY date
ORDER BY 1,2


 -- Total population Vs vaccinations
 -- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
--		  , (RollingPeopleVaccinated/Population)*100
FROM [dbo].[CovidDeaths] as dea 
JOIN [dbo].[CovidVaccinations] as vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


 -- Using of CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
          SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
--		  , (RollingPeopleVaccinated/Population)*100
FROM [dbo].[CovidDeaths] as dea 
JOIN [dbo].[CovidVaccinations] as vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopVsVac


 -- Using TEMP Table to perform Calculation on Partition By in previous query

DROP TABLE if EXISTS  #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
          SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
--		  , (RollingPeopleVaccinated/Population)*100
FROM [dbo].[CovidDeaths] as dea 
JOIN [dbo].[CovidVaccinations] as vac
   ON dea.location = vac.location
   and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



 -- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
          SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
--		  , (RollingPeopleVaccinated/Population)*100
FROM [dbo].[CovidDeaths] as dea 
JOIN [dbo].[CovidVaccinations] as vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated