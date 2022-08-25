Select *
From PortfolioProject1.dbo.CovidDeaths 
order by 3,4
 
--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3 ,4 
 
--Select data that we is going to be used
 
 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject1.dbo.CovidDeaths 
 where continent is not null
 order by 1,2
 
 --Looking at the total cases vs total deaths
 -- Shows Likelihood of dying if you contract COVID19 in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject1.dbo.CovidDeaths 
 Where location like '%canada%'
  and continent is not null
 order by 1,2
 
 -- Looking at total cases vs population
 --Shows What population got COVID19
 Select location, date, total_cases, Population, (total_cases/Population)*100 as PopulationPercentage
 From PortfolioProject1.dbo.CovidDeaths 
 Where location like '%Canada%'
 order by 1,2
 
 -- Looking at countries with highest infection rate compared to population
  Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PopulationInfectedPercentage
 From PortfolioProject1.dbo.CovidDeaths 
-- Where location like '%Canada%'
 Group by Location,Population
 order by PopulationInfectedPercentage desc
 
 --Showing countries with highest death count per population
   Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject1.dbo.CovidDeaths 
-- Where location like '%Canada%'
Where not Continent = ''
 Group by Location, Population 
 order by TotalDeathCount desc
 
 --Breaking it down by Continent
 
 --Showing the continent with the highest death count per population
     Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject1.dbo.CovidDeaths 
-- Where location like '%Canada%'
 where not Continent= ''
 Group by Continent
 order by TotalDeathCount desc 
 
 --Global numbers 
 
 Select SUM(new_cases) as  total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
 From PortfolioProject1.dbo.CovidDeaths 
 --Where location like '%canada%'
 where not continent=''
 --group by date
 order by 1,2 
 


  Select SUM(new_cases) as  total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
 From PortfolioProject1.dbo.CovidDeaths 
 --Where location like '%canada%'
 where not continent=''
 --group by date
 order by 1,2 
 
 
 -- Total population vs vaccinations
 
 Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
 , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
 order by dea. location, dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population)*100
 from PortfolioProject1.dbo.CovidDeaths dea
 join PortfolioProject1.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
where not dea.continent='' 
 order by 2,3
 
 --- Use CTE
 with PopVsVac (Continent, Location, Date, Population, new_vaccinations,  RollingPeopleVaccinated)
 as
 (
  Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
 , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
 Order by dea.location, dea. date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from PortfolioProject1.dbo.CovidDeaths dea
 join PortfolioProject1.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
where not dea.continent='' 
--order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopVsVac
 
 --TempTable
 
 Drop table if exists #PercentPopulationVaccinatd
 Create Table #PercentPopulationVaccinatd
 
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert Into #PercentPopulationVaccinatd
  Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
 , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
 Order by dea.location, dea. date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from PortfolioProject1.dbo.CovidDeaths dea
 join PortfolioProject1.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
--where not dea.continent='' 
--order by 2,3
 
 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinatd
 
--- Creating View to store date for later visualizations
 
 Create View PercentPopulationVaccinatd as
 Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
 , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
 Order by dea.location, dea. date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 from PortfolioProject1.dbo.CovidDeaths dea
 join PortfolioProject1.dbo.CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
where not dea.continent='' 
--order by 2,3
 
Select *
From PercentPopulationVaccinatd 
