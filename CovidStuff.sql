SELECT *
FROM PortfolioProject.. CovidDeaths$
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.. CovidVaccinations$
--order by 3,4


-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.. CovidDeaths$
order by 1,2


-- Looking at total cases vs total deaths in countries.

Select Location, date, total_cases, total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths$
Where location like '%states%'
order by 1,2


-- Look at Total Cases vs Population
-- Shows which percent of population has gotten Covid


Select Location, date, Population, total_cases, (Total_cases/population)*100 as InfectedPopulationPercent
From PortfolioProject.. CovidDeaths$
Where location like '%states%'
order by 1,2


-- Look at which countries have the highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as InfectedPopulationPercent
From PortfolioProject.. CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by InfectedPopulationPercent desc

-- Which Countries had the Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT (2 ways)
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--- THIS IS THE RIGHT WAY TO DO THE ABOVE CALC (need to remove income brackets) ---
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc



-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
From PortfolioProject.. CovidDeaths$
where continent is not null
group by date
order by 1,2


-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--- USE CTE (# of columns must match in CTE + Main Data Set)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3