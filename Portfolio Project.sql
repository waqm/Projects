SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4;


-- Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

SELECT TOP (100) *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;


-- looking at totalCases vs totalDeaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group BY location
ORDER BY totaldeaths DESC;

-- looking at totalCases vs Population
-- shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infectionLevel
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%States%'
ORDER BY 1,2;


--looking at countries with highest infection rate compared to populations

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/MAX(population))*100 AS infectionLevel, MAX(total_deaths)
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infectionLevel DESC;


-- showing countries with highest death counts per population

SELECT continent, location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC;


--  Let's break things down by continent

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- showing continent with the highest death count

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--GLOBAL NUMBERS

-- global death rate
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


-- LOOKING AT Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingVaccinations/Population)*100 AS VaccinationRate
FROM PopvsVac
ORDER BY Location, Date



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacccinations -- this is rolling addition of vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingVaccinations/Population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated
ORDER BY location, date



-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS


-- population vaccination percentage

USE PortfolioProject;
GO -- this is to indicate the end of a batch of statements
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- death percentage

USE PortfolioProject;
GO -- this is to indicate the end of a batch of statements
CREATE VIEW DeathPercentage AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths

-- total deaths, each country

USE PortfolioProject;
GO -- this is to indicate the end of a batch of statements
CREATE VIEW TotalDeaths AS
SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeaths 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group BY location 