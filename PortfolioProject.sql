SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%turkey%'
ORDER BY 1,2


--Loooking at Total Cases vs Population
--Shows what percentage of population got Covid
--(covid olanlarýn nüfusun yüzde kaçýna denk geldiðini gösteriyor)

SELECT location,date,population,total_cases,(total_cases/population)*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%turkey%'
order by 1,2




--Looking at Countries with Highest Infection Rate compared to Population
--Nüfusa kýyasla enfeksiyon(covid) oranýnýn en yüksek olduðu ülkelere bakalým

SELECT 
location,
population,
MAX(total_cases) HighestInfectionCount,
max((total_cases/population)*100) PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY 4 DESC



--Showing Countries with Highest Dearh Count per Population
--nüfus baþýna en yüksek ölüm sayýsý
--total_deaths nvarchar 255 olduðundan dolayý bunu sayýsal deðiþkene(int) dönüþtürmemiz gerekli cast ile
--sorguyu yazdýðýmýzda ülkeler dýþýnda dünya,avrupa,afrika gibi kýtalarda gelecek bunlarý kaldýrmamýz gerekli
--Contient sütunu boþ olduðunda location ülke olarak gelmemekte bu yüzden Contienti not null yani boþ olmayanlarý seçiyoruz


SELECT 
location,
max(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY 2 DESC



SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing contintents with the highest death count per population
--þÝMDÝDE YANLIZCA KITLARA GÖRE EN YÜKSEK ÖLÜM SAYILARINA BAKIYORUZ

SELECT 
continent,
max(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY 2 DESC



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at Total Population vs Vaccinations
--toplam nüfusa karþýn aþý ya bakýcaz

SELECT 
dea.continent,
dea.location,
dea.date,dea.population,
vac.new_vaccinations,
sum(CONVERT (int,vac.new_vaccinations))
	OVER (Partition by dea.Location order by dea.Location,dea.date) RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100	
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3





--use cte


WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(CONVERT (int,vac.new_vaccinations))
	OVER (Partition by dea.Location order by dea.Location,dea.date) RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100	
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac





--TEMP TABLE
--geçici tablo oluþturuyoruz


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(CONVERT (int,vac.new_vaccinations))
	OVER (Partition by dea.Location order by dea.Location,dea.date) RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100	
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from PercentPopulationVaccinated



