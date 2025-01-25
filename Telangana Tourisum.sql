create database telangana;

use telangana;

CREATE TABLE domastic (
    district TEXT,
    months VARCHAR(30),
    visitors BIGINT,
    years YEAR
);

SELECT 
    *
FROM
    domastic;

CREATE TABLE foreigns (
    district TEXT,
    months VARCHAR(30),
    visitors BIGINT,
    years YEAR
);

SELECT 
    *
FROM
    foreigns;

/*1. List  down the top 10 districts that have  the highest number of domastic vistors overoll (2019-2023)*/
 
 SELECT 
    district, SUM(visitors) AS domestic_visitors
FROM
    domastic
GROUP BY district
ORDER BY domestic_visitors DESC
LIMIT 10;
 
 /*2.list down the top 3 districts based on compounded annual growth rate (CAGR) of visitors between (2019-2023) [growing]*/
with Year_Range as
(select district, min(years) as start_year,max(years) as end_year
from domastic
group by district
),
visitors_count as (
select d.district,yr.start_year,yr.end_year,
sum(case when d.years=yr.start_year then d.visitors else 0 end) as start_visitors,
sum(case when d.years=yr.end_year then d.visitors else 0 end) as end_visitors
from domastic as d
inner join  Year_Range as yr 
on d.district=yr.district
group by d.district,yr.start_year,yr.end_year)
select district,start_year,end_year,start_visitors,end_visitors,
power((end_visitors*1.0/start_visitors),(1.0/(end_year-start_year)))-1 as CAGR
from visitors_count
group by district
order by CAGR desc
limit 3;
-- Foreign Visitors

with Year_Range as
(select district, min(years) as start_year,max(years) as end_year
from  foreigns
group by district
),
visitors_count as (
select f.district,yr.start_year,yr.end_year,
sum(case when f.years=yr.start_year then f.visitors else 0 end) as start_visitors,
sum(case when f.years=yr.end_year then f.visitors else 0 end) as end_visitors
from  foreigns as f
inner join  Year_Range as yr 
on f.district=yr.district
group by f.district,yr.start_year,yr.end_year)
select district,start_year,end_year,start_visitors,end_visitors,
power((end_visitors*1.0/start_visitors),(1.0/(end_year-start_year)))-1 as CAGR
from visitors_count
group by district
order by CAGR desc
limit 3;

/*3. list down the top 3 districts based on compounded annual growth rate (CAGR) of visitors between (2019-2023) [declined]
*/
-- domestic visitors
with Year_Range as
(select district, min(years) as start_year,max(years) as end_year
from domastic
group by district
),
visitors_count as (
select d.district,yr.start_year,yr.end_year,
sum(case when d.years=yr.start_year then d.visitors else 0 end) as start_visitors,
sum(case when d.years=yr.end_year then d.visitors else 0 end) as end_visitors
from domastic as d
inner join  Year_Range as yr 
on d.district=yr.district
group by d.district,yr.start_year,yr.end_year)
select district,start_year,end_year,start_visitors,end_visitors,
power((end_visitors*1.0/start_visitors),(1.0/(end_year-start_year)))-1 as CAGR
from visitors_count
group by district
order by CAGR asc
limit 3;

-- Foreign Visitors

with Year_Range as
(select district, min(years) as start_year,max(years) as end_year
from  foreigns
group by district
),
visitors_count as (
select f.district,yr.start_year,yr.end_year,
sum(case when f.years=yr.start_year then f.visitors else 0 end) as start_visitors,
sum(case when f.years=yr.end_year then f.visitors else 0 end) as end_visitors
from  foreigns as f
inner join  Year_Range as yr 
on f.district=yr.district
group by f.district,yr.start_year,yr.end_year)
select district,start_year,end_year,start_visitors,end_visitors,
power((end_visitors*1.0/start_visitors),(1.0/(end_year-start_year)))-1 as CAGR
from visitors_count
group by district
having CAGR is not null
order by CAGR asc
limit 3;

/*4.what are the peak and low season months for  Hyderabad based on the data from 2019 to 2023 for hyderabad district?*/
SELECT 
    d.months AS months,
    SUM(d.visitors) AS domastic_total,
    SUM(f.visitors) AS foreign_total,
    (SUM(d.visitors) + SUM(f.visitors)) AS total
FROM
    domastic AS d
        JOIN
    foreigns AS f ON d.months = f.months
        AND d.years = f.years
        AND d.district = f.district
WHERE
    d.district = 'Hyderabad'
GROUP BY months
ORDER BY total DESC;

-- low 
SELECT 
    d.months AS months,
    SUM(d.visitors) AS domastic_total,
    SUM(f.visitors) AS foreign_total,
    (SUM(d.visitors) + SUM(f.visitors)) AS total
FROM
    domastic AS d
        JOIN
    foreigns AS f ON d.months = f.months
        AND d.years = f.years
        AND d.district = f.district
WHERE
    d.district = 'Hyderabad'
GROUP BY months
ORDER BY total ASC;

/* 5. show the top and bottom 3 districts with high  domestic to foreign tourist ratio?*/
SELECT 
    d.district,
    SUM(d.visitors) AS total_domastic_visitors,
    SUM(f.visitors) AS total_foreign_visitors,
    CASE
        WHEN SUM(f.visitors) = 0 THEN NULL
        ELSE SUM(d.visitors) * 1.0 / SUM(f.visitors)
    END AS domestic_to_foreign_ratio
FROM
    domastic AS d
        LEFT JOIN
    foreigns AS f ON d.district = f.district
GROUP BY d.district
ORDER BY domestic_to_foreign_ratio DESC
LIMIT 3;

-- bottom 3
SELECT 
    d.district,
    SUM(d.visitors) AS total_domastic_visitors,
    SUM(f.visitors) AS total_foreign_visitors,
    CASE
        WHEN SUM(f.visitors) = 0 THEN NULL
        ELSE SUM(d.visitors) * 1.0 / SUM(f.visitors)
    END AS domestic_to_foreign_ratio
FROM
    domastic AS d
        LEFT JOIN
    foreigns AS f ON d.district = f.district
GROUP BY d.district
ORDER BY domestic_to_foreign_ratio ASC
LIMIT 3;

/* 6. list the top & bottom 5 districts based on 'population to tourist ratio' ratio in 2019?*/
SELECT 
    d.district AS districts,
    SUM(d.visitors) AS domastic_total,
    SUM(f.visitors) AS foreign_total,
    SUM(d.visitors) + SUM(f.visitors) AS total_tourist,
    (35003674 / SUM(d.visitors) + SUM(f.visitors)) AS population_to_tourist_ratio
FROM
    domastic AS d
        JOIN
    foreigns AS f ON d.months = f.months
        AND d.years = f.years
        AND d.district = f.district
WHERE
    d.years = 2019
GROUP BY districts
ORDER BY population_to_tourist_ratio DESC
LIMIT 5;

-- bottom

SELECT 
    d.district AS districts,
    SUM(d.visitors) AS domastic_total,
    SUM(f.visitors) AS foreign_total,
    SUM(d.visitors) + SUM(f.visitors) AS total_tourist,
    (35003674 / SUM(d.visitors) + SUM(f.visitors)) AS population_to_tourist_ratio
FROM
    domastic AS d
        JOIN
    foreigns AS f ON d.months = f.months
        AND d.years = f.years
        AND d.district = f.district
WHERE
    d.years = 2019
GROUP BY districts
ORDER BY population_to_tourist_ratio ASC
LIMIT 5;

/*7.what will be the projected number of domestic and foreign torists in Hyderabad in 2025 based on the growth rate
from previous years?*/

-- Calculate CAGR and Projected Domestic Tourists for Hyderabad
WITH DomesticStartEnd AS (
    SELECT 
        years AS start_year, 
        visitors AS start_visitors
    FROM domastic
    WHERE district = 'Hyderabad'
    ORDER BY years ASC
    LIMIT 1
), 
DomesticLatest AS (
    SELECT 
        years AS end_year, 
        visitors AS end_visitors
    FROM domastic
    WHERE district = 'Hyderabad'
    ORDER BY years DESC
    LIMIT 1
)
SELECT 
    ds.start_year,
    dl.end_year,
    ds.start_visitors,
    dl.end_visitors,
    POWER(dl.end_visitors * 1.0 / ds.start_visitors, 1.0 / (dl.end_year - ds.start_year)) - 1 AS domestic_cagr,
    dl.end_visitors * POWER(1 + (POWER(dl.end_visitors * 1.0 / ds.start_visitors, 1.0 / (dl.end_year - ds.start_year)) - 1), 2025 - dl.end_year) AS projected_domestic_visitors_2025
FROM DomesticStartEnd ds
CROSS JOIN DomesticLatest dl;

-- Calculate CAGR and Projected Foreign Tourists for Hyderabad
WITH ForeignStartEnd AS (
    SELECT 
        years AS start_year, 
        visitors AS start_visitors
    FROM foreigns
    WHERE district = 'Hyderabad'
    ORDER BY years ASC
    LIMIT 1
), 
ForeignLatest AS (
    SELECT 
        years AS end_year, 
        visitors AS end_visitors
    FROM foreigns
    WHERE district = 'Hyderabad'
    ORDER BY years DESC
    LIMIT 1
)
SELECT 
    fs.start_year,
    fl.end_year,
    fs.start_visitors,
    fl.end_visitors,
    POWER(fl.end_visitors * 1.0 / fs.start_visitors, 1.0 / (fl.end_year - fs.start_year)) - 1 AS foreign_cagr,
    fl.end_visitors * POWER(1 + (POWER(fl.end_visitors * 1.0 / fs.start_visitors, 1.0 / (fl.end_year - fs.start_year)) - 1), 2025 - fl.end_year) AS projected_foreign_visitors_2025
FROM ForeignStartEnd fs
CROSS JOIN ForeignLatest fl;

/*8. estimate the projected revenue for Hyderabd in 2025 based on average spend per tourist*/

-- Step 1: Calculate projected tourists for Hyderabad in 2025
WITH DomesticStartEnd AS (
    SELECT 
        years AS start_year, 
        visitors AS start_visitors
    FROM domastic
    WHERE district = 'Hyderabad'
    ORDER BY years ASC
    LIMIT 1
), 
DomesticLatest AS (
    SELECT 
        years AS end_year, 
        visitors AS end_visitors
    FROM domastic
    WHERE district = 'Hyderabad'
    ORDER BY years DESC
    LIMIT 1
), 
ForeignStartEnd AS (
    SELECT 
        years AS start_year, 
        visitors AS start_visitors
    FROM foreigns
    WHERE district = 'Hyderabad'
    ORDER BY years ASC
    LIMIT 1
), 
ForeignLatest AS (
    SELECT 
        years AS end_year, 
        visitors AS end_visitors
    FROM foreigns
    WHERE district = 'Hyderabad'
    ORDER BY years DESC
    LIMIT 1
)
SELECT 
    -- Projected tourists for 2025
    dl.end_visitors * POWER(1 + (POWER(dl.end_visitors * 1.0 / ds.start_visitors, 1.0 / (dl.end_year - ds.start_year)) - 1), 2025 - dl.end_year) AS projected_domestic_tourists_2025,
    fl.end_visitors * POWER(1 + (POWER(fl.end_visitors * 1.0 / fs.start_visitors, 1.0 / (fl.end_year - fs.start_year)) - 1), 2025 - fl.end_year) AS projected_foreign_tourists_2025,

    -- Revenue Estimation
    (dl.end_visitors * POWER(1 + (POWER(dl.end_visitors * 1.0 / ds.start_visitors, 1.0 / (dl.end_year - ds.start_year)) - 1), 2025 - dl.end_year)) * 500 AS projected_domestic_revenue, -- Assuming average spend of 500 per domestic tourist
    (fl.end_visitors * POWER(1 + (POWER(fl.end_visitors * 1.0 / fs.start_visitors, 1.0 / (fl.end_year - fs.start_year)) - 1), 2025 - fl.end_year)) * 3000 AS projected_foreign_revenue -- Assuming average spend of 3000 per foreign tourist
FROM DomesticStartEnd ds
CROSS JOIN DomesticLatest dl
CROSS JOIN ForeignStartEnd fs
CROSS JOIN ForeignLatest fl;












