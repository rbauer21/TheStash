--Select Location, date, total_cases, total_deaths, population
--from CovidDeath
--order by location, date

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_rate
from CovidDeath
Where location like '%Canada%'
and continent is not null
order by location, date

Select location, date, population,  total_cases, (total_cases/population)*100 as infected_rate
from CovidDeath
Where location like '%Canada%'
and continent is not null
order by location, date

Select location, population, Max(cast(total_deaths as int)) as highest_deaths, Max((total_deaths/population))*100 as highest_death_rate
From CovidDeath
Where continent is not null
group by location, population
order by highest_death_rate desc

Select location, population, Max(cast(total_cases as int)) as highest_cases, Max((total_deaths/population))*100 as highest_infected_rate
From CovidDeath
where continent is not null
group by location, population
order by highest_infected_rate desc

Select location, continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is not null
Group by location, continent
order by TotalDeathCount desc


Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as death_percentage from CovidDeath
Where continent is not null
Group By date

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as death_percentage from CovidDeath
Where continent is not null
;

--Using CTE to create a rolling count of people vaccinated including location
With PopVac(continent, location, date, population, new_vaccinations, rolling_vac)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, Sum(CONVERT(bigint, V.new_vaccinations)) over (Partition by D.location Order by D.location, D.date) as rolling_vac
From CovidDeath D
join CovidVacc V
	on D.location = V.location
	and D.date = V.date
where D.continent is not null
)
Select *, (rolling_vac/population)*100 as rolling_vac_percent
From PopVac