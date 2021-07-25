 -- Total Cases vs Total Death
 -- Show likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeath
WHERE location like '%states%'
ORDER BY 1,2
 

-- Looking at Total Cases vs Population
-- % of population got Covid
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeath
WHERE location like '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeath
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC 


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- Showing Continent with highest death cpunt

SELECT continent, MAX(total_deaths) AS TotalDeathCount 
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) AS totalDeath, SUM(new_deaths)/SUM(new_cases)*100  AS DeathPercentage
FROM CovidDeath
WHERE continent IS NOT NULL

ORDER BY 1,2
 


 -- Looking at Total Population vs Vaccinattions

 SELECT 
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
 FROM  CovidDeath dea
 JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, rollingPeopleVaccinated)
AS
(
SELECT 
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
 FROM  CovidDeath dea
 JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,
(rollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT 
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
 FROM  CovidDeath dea
 JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 
SELECT *,
(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS

 SELECT 
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations,
 SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
 FROM  CovidDeath dea
 JOIN CovidVaccinations vac
	ON	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL