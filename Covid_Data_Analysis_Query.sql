Select * 
From CovidAnalysis..['CovidDeaths']
order by 3,4

Select * 
From CovidAnalysis..['CovidVaccinations']
order by 3,4

-- Data Selection
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidAnalysis..['CovidDeaths']
order by 1,2

-- Total Cases VS Total Deaths (Death Percentage)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis..['CovidDeaths']
where location like 'India'
order by 1,2

-- Total Cases VS Populations ( Shows what percentage of population got Covid)
Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationGotCovid
From CovidAnalysis..['CovidDeaths']
where location like 'India'
order by 1,2

-- Countries with highest infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 
as PercentagePopulationInfected 
From CovidAnalysis..['CovidDeaths']
--where location like 'India'
Group by Location, population
order by PercentagePopulationInfected Desc

-- Countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount 
From CovidAnalysis..['CovidDeaths']
--where location like 'India'
where continent is not NULL
Group by Location, population
order by TotalDeathCount Desc

-- Details by Continent
Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
From CovidAnalysis..['CovidDeaths']
where continent is NULL
Group by location
order by TotalDeathCount Desc

-- Continent with highest death count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount 
From CovidAnalysis..['CovidDeaths']
where continent is not NULL
Group by continent
order by TotalDeathCount Desc

-- Global Analysis
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidAnalysis..['CovidDeaths']
where continent is not null
group by date
order by 1

-- Total Population Vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidAnalysis..['CovidDeaths'] as dea
JOIN CovidAnalysis..['CovidVaccinations'] as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as PeopleVaccinated
From CovidAnalysis..['CovidDeaths'] as dea
JOIN CovidAnalysis..['CovidVaccinations'] as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopVSVac (Continent, location, date, population, new_vaccination, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as PeopleVaccinated
From CovidAnalysis..['CovidDeaths'] as dea
JOIN CovidAnalysis..['CovidVaccinations'] as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (PeopleVaccinated/population)*100
From PopVSVac

-- Temp Table 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From CovidAnalysis..['CovidDeaths'] as dea
JOIN CovidAnalysis..['CovidVaccinations'] as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From CovidAnalysis..['CovidDeaths'] as dea
JOIN CovidAnalysis..['CovidVaccinations'] as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

