---- Join Query ----
select *
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
order by 1,2

---- Looking At Total Poulation vs Vaccination ----

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
order by 1,2

---- Using over partition by ----

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(convert(bigint,vaccine.new_vaccinations)) over (partition by death.location order by death.location,
death.date) as RolligPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
order by 1,2


---- using  CTE ----
with vaccinatedData  as(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(convert(bigint,vaccine.new_vaccinations)) over (partition by death.location order by death.location,
death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
)

select Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
as NewlyVaccinated, Max(RollingPeopleVaccinated) AS MaximumRollingPeopleVaccinated,
(
        SELECT MAX(RollingPeopleVaccinated) 
        FROM vaccinatedData
    ) AS MaximumRollingPeopleVaccinated

from vaccinatedData

order by continent, location, date;

---- same same but different ----

WITH vaccinatedData AS (
    SELECT 
        death.continent, 
        death.location, 
        death.date, 
        death.population, 
        vaccine.new_vaccinations,
        SUM(CONVERT(BIGINT, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths$ death
    JOIN 
        PortfolioProject..CovidVaccinations$ vaccine
    ON 
        death.location = vaccine.location
        AND death.date = vaccine.date
    WHERE 
        death.continent IS NOT NULL
)

SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingPeopleVaccinated,
    (RollingPeopleVaccinated / population) * 100 AS PercentageVaccinated
FROM 
    vaccinatedData
ORDER BY 
    continent, location, date;


----	Temp Table   ----
Drop table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population  numeric,
    new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
 insert into #PercentPopulationVaccinated
 Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
Sum(convert(bigint,vaccine.new_vaccinations)) over (partition by death.location order by death.location,
death.date) as RolligPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
--order by 1,2

select *, (RollingPeopleVaccinated / population) * 100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


