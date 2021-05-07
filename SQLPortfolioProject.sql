Select * --Select all
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths, Percentage
--Shows the likelihood of dying inf you contract COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%germany%'
order by 1,2

--looking at the total cases versus the population
--Shows what percentage of population got COVID
Select location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking which country has the highest infection rate compared to the population
Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
order by 4 desc


--Showing Country with Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


--Breaking down by Continent

--Showing continents with the highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Global Numbers
Select date, Sum(new_cases) as totalCases, Sum(cast(new_deaths as int)) as totalDeaths, (Sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
order by 1,2


--Looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- breaking it up by location, because the counter will reset at every new location as aggregation function
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Variant CTE
With PopvsVac(continent, location,date,population,new_vaccinations, RollingPeopleVaccinated) --number of columns in CTE needs to match number of columns in parantheses
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- breaking it up by location, because the counter will reset at every new location as aggregation function
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select* , (RollingPeopleVaccinated/population)*100 as PercentageVaccinatedPopulation
From PopvsVac

--Variant TempTable

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- breaking it up by location, because the counter will reset at every new location as aggregation function
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select* , (RollingPeopleVaccinated/population)*100 as PercentageVaccinatedPopulation
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- breaking it up by location, because the counter will reset at every new location as aggregation function
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

