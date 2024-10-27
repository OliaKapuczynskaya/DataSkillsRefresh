-- Total cases vs total deaths
SELECT	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 5 DESC

-- Deaths % in total number of cases in USA
SELECT	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE (total_deaths/total_cases)*100  = (
SELECT MAX(total_deaths/total_cases)*100 
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states' 
)

-- Highest infection
SELECT	Location, Population, MAX(total_cases) AS HighestInfection, MAX(total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population

-- Highest deathcount per population
SELECT	Location, MAX(CAST(total_deaths as int)) AS DeathsNum
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC

-- VIEWS --

-- Highest deathcount per population
SELECT	continent, SUM(CAST(total_deaths as int)) AS DeathsNum
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- GLOBAL NUMBERS
SELECT 
    date, 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
    (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) AS 
(SELECT dea.continent, dea.location, Dea.date, Dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY Vac.location order by Vac.location, Vac.date) as RollingPeopleVaccd
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccs as Vac
ON Dea.location = Vac.location
and dea.date = vac.date
WHERE Dea.continent is not null
AND Dea.location = 'Canada'
)
Select * , (RollingPeopleVaccinated/Population) as PercentageVaccinatedPeople
FROM PopvsVac
ORDER BY 1,2,3

-- TEMP TABLE
CREATE TABLE #PercentPopulationVaccd
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_Vaccs numeric,
RollingPeopleVaccd numeric
)

Insert into #PercentPopulationVaccd
SELECT dea.continent, dea.location, Dea.date, Dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY Vac.location order by Vac.location, Vac.date) as RollingPeopleVaccd
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccs as Vac
ON Dea.location = Vac.location
and dea.date = vac.date
WHERE Dea.continent is not null
AND Dea.location = 'Canada'

Select *, (RollingPeopleVaccd/Population) as PercentageVaccinatedPeople
FROM #PercentPopulationVaccd
ORDER BY 1,2,3

-- Creating VIEW
Create View PercentPopulationVaccd as
SELECT dea.continent, dea.location, Dea.date, Dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY Vac.location order by Vac.location, Vac.date) as RollingPeopleVaccd
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccs as Vac
ON Dea.location = Vac.location
and dea.date = vac.date
WHERE Dea.continent is not null
AND Dea.location = 'Canada'
