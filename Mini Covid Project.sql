SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
Select Location, date, total_cases,  total_deaths, CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%macedonia%'
order by 5 desc 

Select Location, date, total_cases,  total_deaths, CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 desc 

Select Location, date, total_cases,  population, CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%macedonia%'
order by 1,2 

Select location, population, MAX(CAST(total_cases as float)) as HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

--total deaths in macedonia
Select location, Max(cast(Total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where location like '%macedonia%'
group by location 
Order by TotalDeathCount desc

--showing continents with the  highest death count per population 
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by  continent
order by TotalDeathCount desc



SELECT --date, 
       SUM(CAST(new_cases AS FLOAT)) AS total_cases, 
       SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, 
       (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY --date,
	total_cases DESC;
--ORDER BY 1,2 DESC; --same 

--use CTE
With PopVsVacc (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--and new_vaccinations is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVacc

--temp table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, Sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
	--and new_vaccinations is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

--Drop view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated