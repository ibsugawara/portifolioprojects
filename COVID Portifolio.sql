SELECT *
FROM analystdb.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM ANALYSTDB.CovidDeaths
WHERE location LIKE '%brazil%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS InfecctionPercentage
FROM ANALYSTDB.CovidDeaths
WHERE location LIKE '%brazil%'
AND continent IS NOT NULL AND continent <> ''
ORDER BY 1,2;

-- Looking at Countries with Highest Infecction Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfecctionCount, MAX((total_cases/population)) * 100 AS InfecctionPercentage
FROM ANALYSTDB.CovidDeaths
GROUP BY location, population
ORDER BY InfecctionPercentage DESC;

-- Looking at Countries with Highest Death Rate per Population
SELECT Location, MAX(total_deaths) AS HighestDeathCount
FROM ANALYSTDB.CovidDeaths
WHERE continent <> ''
GROUP BY location
ORDER BY HighestDeathCount DESC;

/* Breaking things down by continent
Showing continents with the highest death count */
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM ANALYSTDB.CovidDeaths
WHERE continent = ''
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Global numbers
SELECT 
  SUM(total_cases) AS total_cases, 
  SUM(total_deaths) AS total_deaths,
  (SUM(total_deaths)/SUM(total_cases))*100 AS death_percentage
FROM analystdb.coviddeaths
WHERE continent = ''
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM analystdb.coviddeaths dea
JOIN analystdb.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
ORDER BY 2, 3;

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, peoplevaccinated) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM analystdb.coviddeaths dea
JOIN analystdb.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> '')
SELECT *, (peoplevaccinated/population) * 100 FROM PopVsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TEMPORARY TABLE IF EXISTS percentpopulationvaccinated;
DROP TABLE IF EXISTS percentpopulationvaccinated;
CREATE TEMPORARY TABLE percentpopulationvaccinated (
  continent VARCHAR(255),
  location VARCHAR(255),
  date DATE,
  population DECIMAL(20,2),
  new_vaccinations DECIMAL(20,2),
  peoplevaccinated DECIMAL(20,2)
);

INSERT INTO percentpopulationvaccinated
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  COALESCE(NULLIF(vac.new_vaccinations, ''), 0) AS new_vaccinations,
  SUM(COALESCE(NULLIF(vac.new_vaccinations, ''), 0)) 
    OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM 
  analystdb.coviddeaths dea
JOIN 
  analystdb.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date;

SELECT *, (peoplevaccinated/population) * 100 AS percentvaccinated
FROM percentpopulationvaccinated;


-- Creating View to store data for later visualization
CREATE VIEW vw_percentpopulationvaccinated AS
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(COALESCE(vac.new_vaccinations, 0)) 
    OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM 
  analystdb.coviddeaths dea
JOIN 
  analystdb.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent <> '';

SELECT * FROM percentpopulationvaccinated;
