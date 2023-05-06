--Data from (03/01/2020 to 04/05/2023)
SELECT * FROM `sample-project-349911.CovidProject.CovidDeaths` 
WHERE continent is NOT NULL
ORDER BY 3,4;

SELECT * FROM `sample-project-349911.CovidProject.CovidVaccinations` 
ORDER BY 3,4
LIMIT 1000;


SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM `sample-project-349911.CovidProject.CovidDeaths` 
ORDER BY 1,2;

--Total cases vs Total deaths
--Shows likelihood of dying from Covid in India (03/01/2020 to 04/05/2023)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM `sample-project-349911.CovidProject.CovidDeaths` 
WHERE location = 'India'
AND continent is NOT NULL
ORDER BY 1,2;

--Total cases vs People hospitalized in Poland
SELECT location, date, total_cases, hosp_patients, (CAST(hosp_patients AS INT64)/total_cases)*100 AS HospitalPercent
FROM `sample-project-349911.CovidProject.CovidDeaths` 
WHERE location = 'Poland'  
AND continent is NOT NULL
ORDER BY 1,2;

--Total cases vs ICU patients in the US
SELECT location, date, total_cases, icu_patients, (icu_patients/total_cases)*100 AS CriticalPercent
FROM `sample-project-349911.CovidProject.CovidDeaths` 
WHERE location = 'United States'  
AND continent is NOT NULL
ORDER BY 1,2;

--Total Cases vs Population
--Shows what percentage of population had Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercent
FROM `sample-project-349911.CovidProject.CovidDeaths` 
WHERE location = 'India'
AND continent is NOT NULL
ORDER BY 1,2;

--Countries with Highest infection rate per Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercent
FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY population, location
ORDER BY CasePercent desc;

--Countries with Highest death count per Population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HighestDeathCount desc;

--Countries with Highest number of hospitalizations
SELECT location, MAX(hosp_patients) AS HighestHospitalization
FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HighestHospitalization desc
LIMIT 40;

--Countries with Highest number of ICU patients
SELECT location, MAX(icu_patients) AS HighestCritPatients
FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HighestCritPatients desc
LIMIT 42;

--Continents with Highest death count per Population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE location = 'India'
WHERE continent is NULL
AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY HighestDeathCount desc;

--Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM `sample-project-349911.CovidProject.CovidDeaths` dea
JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
ORDER BY 2,3;

--Percent of population tested per day in India
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_tests, (vac.new_tests/dea.population)*100 AS TestPercent
FROM `sample-project-349911.CovidProject.CovidDeaths` dea
JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
AND dea.location = 'India'
ORDER BY 2,3;

--Countries with the Highest tests conducted
SELECT dea.location, MAX(vac.total_tests) AS HighestTestCount
FROM `sample-project-349911.CovidProject.CovidDeaths` dea
JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
GROUP BY dea.location
ORDER BY HighestTestCount desc
LIMIT 188;

--Rolling Vaccination Count Partitioned by Location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCount
FROM `sample-project-349911.CovidProject.CovidDeaths` dea
JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
ORDER BY 2,3;

--CTE to compare Rolling Vaccination Count to Total Population
WITH PopvsVac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCount
FROM `sample-project-349911.CovidProject.CovidDeaths` dea
JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is NOT NULL
--ORDER BY 2,3;
)
SELECT * , (PeopleVaccinatedCount/population)*100 AS PeopleVaccinatedPercent
FROM PopvsVac;

--Creating Views to store data for later Visualizations
--Create View CovidProject.ContinentHighestDeaths AS
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinatedCount
--FROM `sample-project-349911.CovidProject.CovidDeaths` dea
--JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
--ON dea.location = vac.location
--AND dea.date = vac.date 
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3;

--Create View CovidProject.IndiaCovidPercent AS 
--SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercent
--FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE location = 'India'
--AND continent is NOT NULL
--ORDER BY 1,2;

--Create View CovidProject.HighestHospitalPatients AS 
--SELECT location, MAX(hosp_patients) AS HighestHospitalization
--FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE continent is NOT NULL
--GROUP BY location
--ORDER BY HighestHospitalization desc
--LIMIT 40;

--Create View CovidProject.HighestICUPatients AS 
--SELECT location, MAX(icu_patients) AS HighestCritPatients
--FROM `sample-project-349911.CovidProject.CovidDeaths` 
--WHERE continent is NOT NULL
--GROUP BY location
--ORDER BY HighestCritPatients desc
--LIMIT 42;

--Create View CovidProject.NewVaccinations AS
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
--FROM `sample-project-349911.CovidProject.CovidDeaths` dea
--JOIN `sample-project-349911.CovidProject.CovidVaccinations` vac
--ON dea.location = vac.location
--AND dea.date = vac.date 
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3;

