
Select *
From PortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortofolioProject..CovidDeaths
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases VS Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location = 'Indonesia'
and continent is not null
Order by 1,2

-- Looking at Total Cases VS Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortofolioProject..CovidDeaths
----Where location = 'Indonesia'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
	PercentagePopulationInfected
From PortofolioProject..CovidDeaths
----Where location = 'Indonesia'
Group by location, population
Order by PercentagePopulationInfected Desc

-- Showing Countries with Highest Death Count per Population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
----Where location = 'Indonesia'
Where continent is not null
Group by location
Order by TotalDeathCount Desc

-- Lets Break Things Down by Continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
----Where location = 'Indonesia'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

-- Showing continents with the highest detah count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
----Where location = 'Indonesia'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
-- Where location = 'Indonesia'
Where continent is not null
--Group by date
Order by 1,2

-- Looking at Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- With CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac
order by location, date


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
order by location, date


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*
From PercentPopulationVaccinated
order by location,date