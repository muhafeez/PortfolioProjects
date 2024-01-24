Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From CovidVacc
--Order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Order by 1,2



--Looking at Total Cases vs Population
--Shows what percentage of population contracted covid
Select location, date, total_deaths, Population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Order by 1,2

--Looking at Countries with Highest Rate compared to Population
Select location, Population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%pak%'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc


--Showing Countries with the Highest Death Count Per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%pak%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's Break Things Down By Continet
Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%pak%'
Where continent is null
Group by location
Order by TotalDeathCount desc

--Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%pak%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--Aggregate
--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total population vs Vaccinations
-- Partition by will location so the SUM doesn't continue to run. When a new location sta rts, the SUM starts again.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVacc vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVacc vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date Datetime,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVacc vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVacc vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3