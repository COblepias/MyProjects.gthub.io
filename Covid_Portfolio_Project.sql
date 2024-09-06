SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
--WHERE location like 'Can%'
Order by 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3, 4;

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
Order by 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
AND location like 'Ph%'; 

--Select Case when (total_deaths/total_cases) = 0 then null
--Else total_deaths/total_cases
--End;

-- Looking at the total cases vs population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Ph%' 
	AND continent is NOT NULL
ORDER by 1,2 DESC; 

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like 'P%'
GROUP BY location, population
ORDER by 4 DESC; 

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--AND location LIKE 'P%'
--AND location LIKE 'C%'
GROUP BY location
ORDER BY 2 DESC;

-- Let's break things down by continent ( THESE ARE THE CORRECT FIGURES!)
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
--AND location LIKE 'P%'
--WHERE location LIKE 'C%'
GROUP BY location
ORDER BY 2 DESC;

-- Let's break things down by continent ( for the sake of visulalization in tableau, let's break down by continent))
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--AND location LIKE 'P%'
--WHERE location LIKE 'C%'
GROUP BY continent
ORDER BY 2 DESC;

-- Global numbers  
SELECT date, SUM(new_cases) AS Total_New_Cases, SUM(new_deaths) AS Total_New_Deaths, (SUM(new_deaths) / SUM(new_cases)) *100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--AND location like 'Ph%'; 
GROUP BY date;

-- Showing the covid vaccinations table
SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is NULL
--WHERE location like 'Can%'
Order by 3, 4;

-- Joining the two tables
SELECT *
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3;

-- Looking at total population vs vaccination using PARTITION BY (ROLLING COUNT)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_NewVac_Count
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3;

-- Creating CTE to simplify complex queries
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_NewVac_Count)
	AS 
	(
		SELECT 
			dea.continent, 
			dea.location, 
			dea.date, 
			dea.population, 
			vac.new_vaccinations, 
			SUM(CONVERT (int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_NewVac_Count
			FROM 
			PortfolioProject.dbo.CovidDeaths AS dea
		JOIN 
			PortfolioProject.dbo.CovidVaccinations AS vac
			ON dea.location = vac.location
			AND dea.date = vac.date
			WHERE dea.continent is NOT NULL
			--ORDER BY 2, 3;
	)
SELECT*, (Rolling_NewVac_Count/population)*100 AS Rolling_NewVac_Percentage
FROM PopvsVac;





	