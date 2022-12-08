/* COVID 19 DATA EXPLORATION

USED JOINS, Temp tables, Windows functions, Aggregate functions,creating views, converting datatypes

*/

Select *
From CapstoneProject..CovidDeaths
order by 3,4

Select *
From CapstoneProject..CovidDeaths
Where continent is not null
order by 3,4

--To Select Data that we are using to make analysis

Select location,date,total_cases,new_cases,total_deaths,population
From CapstoneProject..CovidDeaths
order by 1,2

--Total cases vs Total deaths

Select location, date, total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CapstoneProject..CovidDeaths
where location like '%states%'
order by 1,2

Select location, date, total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CapstoneProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--total case vs population
--percentage of population infected from covis
Select location, date, total_cases,new_cases,population,(total_cases/population)*100 as DeathPercentage
From CapstoneProject..CovidDeaths
where location like '%states%'
order by 1,2


--looking at countries with highest infection rates compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentageofPopulationInfected
From CapstoneProject..CovidDeaths
Group by Location, Population
order by PercentageofPopulationInfected desc

--Highest death count across countries with respect to population
Select Location, MAX(cast(Total_deaths as int)) as Totaldeathcount
From CapstoneProject..CovidDeaths
Where continent is not null
Group by Location
order by Totaldeathcount desc

--Analysisng data wrt continents
--Continents with highest death rates per population

Select Continent, MAX(cast(Total_deaths as int))as Totaldeathcount
From CapstoneProject..CovidDeaths
Where Continent is not null
Group by continent
order by Totaldeathcount desc

--Globally affected cases
Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CapstoneProject..CovidDeaths
Where Continent is not null
--group by date
order by 1,2

--Total population and vaccinations
--analyses how many percent of population is done with first dose ofcaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as Rollingpeoplevaccinated
From CapstoneProject..CovidDeaths dea
Join CapstoneProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--through Common table expression(CTE) perform calculation on partitiion by previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CapstoneProject..CovidDeaths dea
Join CapstoneProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CapstoneProject..CovidDeaths dea
Join CapstoneProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CapstoneProject..CovidDeaths dea
Join CapstoneProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated
