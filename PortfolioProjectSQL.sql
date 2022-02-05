-- Select *
-- FROM CovidVaccinations
-- Order by 3, 4

-- Select Data that we are going to be using

SELECT location1, date1, total_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Total cases vs Total Deaths
-- Shows chance of dying if you contract Covid-19 in Russia

SELECT location1, date1, total_cases, total_deaths, (total_deaths/total_cases::float)*100 as death_percentage
FROM CovidDeaths
WHERE location1 = 'Russia'
ORDER BY 1, 2;

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid-19 (ignoring repeated infections)

SELECT location1, date1, total_cases, Population, (total_cases/population::float)*100 as infected_percentage
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Countries with highest infection rate

SELECT location1, MAX(total_cases) as HighestInfectionCount, Population, MAX(total_cases/population::float)*100 as InfPopPercent
FROM CovidDeaths
GROUP BY location1, population
ORDER BY InfPopPercent desc;

-- Showing countries with highest death count per Population

SELECT location1, MAX(total_deaths) as HighestDeathCount, Population, MAX(total_deaths/population::float)*100 as DeathPopPercent
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location1, population
ORDER BY DeathPopPercent desc;

-- Global numbers

SELECT date1, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/(SUM(new_cases)::float)*100 as death_percentage
FROM CovidDeaths
--WHERE location1 = 'Russia'
WHERE continent is not null
GROUP BY date1 
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location1 ORDER BY dea.location1, dea.date1)
	as RollingVacPopulation
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location1 = vac.location1
	and dea.date1 = vac.date1
WHERE dea.continent is not NULL
ORDER BY 2, 3;

-- Using CTE

WITH PopvsVac (continent, location1, date1, population, new_vaccinations, RollingPVacPopulation)
as
(
SELECT dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location1 ORDER BY dea.location1, dea.date1)
	as RollingVacPopulation
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location1 = vac.location1
	and dea.date1 = vac.date1
WHERE dea.continent is not NULL
)
SELECT *,(popvsvac.rollingpvacpopulation/popvsvac.population::float)*100
FROM PopvsVac;

--Using Temp Table

/*CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent varchar (50),
Location1 varchar (50),
date1 date,
Population bigint,
new_vaccinations bigint,
RollinVacPopulation bigint
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location1 ORDER BY dea.location1, dea.date1)
	as RollingVacPopulation
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location1 = vac.location1
	and dea.date1 = vac.date1
WHERE dea.continent is not NULL;*/

Select *
FROM percentpopulationvaccinated;

-- Creating view to store data for visualisation

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location1 ORDER BY dea.location1, dea.date1)
	as RollingVacPopulation
FROM coviddeaths as dea
JOIN covidvaccinations as vac
	ON dea.location1 = vac.location1
	and dea.date1 = vac.date1
WHERE dea.continent is not NULL