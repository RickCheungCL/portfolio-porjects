Select * 
From CovidDeaths
where continent is not NULL
order by 3,4



--Pick up what we are going to use

Select Location,date,total_cases,new_cases,total_deaths, population 
From CovidDeaths
order by 1,2


--total cases vs total deaths

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where Location like '%canada%'
order by 1,2

--total cases vs population
--show % of people get covid
Select Location,date,total_cases,Population, (total_cases/Population)*100 as casePercentage
From CovidDeaths
order by 1,2

--HighestInfectionPerCountry vs Population
Select Location,Population,MAX(total_cases) as HighestInfectionPerCountry, MAX((total_cases/Population))*100 as casePercentage
From CovidDeaths
Group by Location,Population 
order by casePercentage desc

--Highest Death count (country)
Select Location,MAX(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not NULL
Group by Location
order by TotalDeathCount desc



--Highest Death count (continent)
Select continent,MAX(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount desc


--global numbers
Select date,SUM(new_cases) as total_cases,SUM(new_deaths) as Total_deaths ,SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
From CovidDeaths
Where continent is not NULL
group by date
order by 1,2


--over the world
Select SUM(new_cases) as total_cases,SUM(new_deaths) as Total_deaths ,SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
From CovidDeaths
Where continent is not NULL
order by 1,2



--explore vaccination and death

Select *
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--explore total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_vacin_Count  --(Rolling_vacin_Count/ dea.population)*100 as 
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3


With PopvsVac (Continent,Location,Date,Population,new_vaccinations, Rolling_vacin_Count)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_vacin_Count  --(Rolling_vacin_Count/ dea.population)*100 as 
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)

--Vaccin Ratio
Select * , (Rolling_vacin_Count/Population)*100 as vaccinRatio
From PopvsVac


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
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * 
From PercentPopulationVaccinated