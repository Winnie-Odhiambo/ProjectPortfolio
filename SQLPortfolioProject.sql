--This shows the likelihood of dying if you contract Covid in Africa
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths
where location like '%Africa%'
Order by 1,2

Select location, date, total_cases, total_deaths
from CovidDeaths
Order by 1,2

Select * from CovidDeaths
where continent is NOT NULL

Select location, date, population,total_cases,  (cast(total_cases as float)/cast(population as float))*100 as PopulationPercentage
from CovidDeaths
--where location like '%Africa%'
Order by 1,2

--Countries with highest infection rates
Select location, population, Max(total_cases) as HighestCases, Max((cast(total_cases as float))/cast(population as float))*100 as HighestInfectionRate
from CovidDeaths
where continent is NOT NULL
Group by location,population
Order by HighestInfectionRate desc

--Countries with the highest deaths
Select location, MAX(cast(Total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is NOT NULL
Group by location
Order by TotalDeaths desc

--Continents with the highest deaths
Select continent, MAX(cast(Total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is NOT NULL
Group by continent
Order by TotalDeaths desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is NOT NULL
Group by continent
Order by TotalDeaths desc

--Death percentage according to dates accross the world
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null and new_cases <> 0
Group by date
Order by 1,2
--Total cases and deaths accross the world
Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null and new_cases <> 0
Order by 1,2

--Covid vaccination table
Select * from CovidVaccinations

--Joining the two tables
Select *
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cd.location
and cd.date=cv.date

--Looking at the toatl population vs vaccination
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cd.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cd.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Using CTE to create a new column created for the RollingPeopleVaccinated to do some arithmetics
--If the number of columns in the table is not the same as the number of columns in the CTE, it will give you an error
with PopVsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cd.location
and cd.date=cv.date
where cd.continent is not null
) 
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--Using Temp Table

Create Table #PercentagePopulationVaccinated
(
continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentagePopulationVaccinated
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) 
OVER (Partition by cd.location Order by cd.location, cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cd.location
and cd.date=cv.date
where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

--Creating views to store data for later visualizations
Create View TotalDeathsPerContinent as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is NOT NULL
Group by continent

Select * from TotalDeathsPerContinent

Create view LikelihoodOfDyingAfrica as
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths
where location like '%Africa%'


