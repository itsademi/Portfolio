use covid;
SELECT 
    *
FROM
    coviddeaths;
SELECT 
    *
FROM
    covidvaccinations;

SELECT 
    *
FROM
    coviddeaths
ORDER BY 3 , 4;

SELECT 
    *
FROM
    covidvaccinations
ORDER BY 3 , 4;

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY 1 , 2;

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    location = 'Germany'
ORDER BY 1 , 2;

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
WHERE
    location = 'Germany'
ORDER BY 1 , 2;

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;

SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT 
    continent,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT 
    SUM(new_cases),
    SUM(new_deaths),
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

#Total population vs Vaccinations
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths AS dea
        JOIN
    covidvaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 2 , 3;

#USing CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths AS dea
        JOIN
    covidvaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

#Temporary tables
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
Insert into PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths AS dea
        JOIN
    covidvaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
SELECT 
    *, (RollingPeopleVaccinated / population) * 100
FROM
    PercentPopulationVaccinated;

#Creating Views
CREATE VIEW PercentPopVac as
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    coviddeaths AS dea
        JOIN
    covidvaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
