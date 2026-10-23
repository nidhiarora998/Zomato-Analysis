create database Zomato_Project;
Use Zomato_Project;
CREATE TABLE zomato_full (
    RestaurantID BIGINT,
    RestaurantName TEXT,
    CountryCode INT,
    City TEXT,
    Address TEXT,
    Locality TEXT,
    LocalityVerbose TEXT,
    Longitude DECIMAL(12,8),
    Latitude DECIMAL(12,8),
    Cuisines TEXT,
    Currency VARCHAR(100),
    Has_Table_booking VARCHAR(10),
    Has_Online_delivery VARCHAR(10),
    Is_delivering_now VARCHAR(10),
    Switch_to_order_menu VARCHAR(10),
    Price_range INT,
    Votes INT,
    Average_Cost_for_two INT,
    Rating VARCHAR(50),
    Datekey_Opening VARCHAR(20)
);
select * FROM zomato_full;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;


LOAD DATA LOCAL INFILE 'C:/Users/Admin/OneDrive/Desktop/Zomato _CSV Master Data_excel r.csv'
INTO TABLE zomato_full
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    RestaurantID,
    RestaurantName,
    CountryCode,
    City,
    Address,
    Locality,
    LocalityVerbose,
    Longitude,
    Latitude,
    Cuisines,
    Currency,
    Has_Table_booking,
    Has_Online_delivery,
    Is_delivering_now,
    Switch_to_order_menu,
    Price_range,
    Votes,
    Average_Cost_for_two,
    Rating,
    Datekey_Opening
);

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

DESCRIBE zomato_full;

SELECT RestaurantID, Latitude, Longitude 
FROM zomato_full 
WHERE Latitude = 0 OR Latitude IS NULL 
LIMIT 20;

Select count(*) from zomato_full;
SELECT COUNT(*) FROM zomato_full WHERE RestaurantID IS NULL;

SELECT RestaurantID, COUNT(*) 
FROM zomato_full 
GROUP BY RestaurantID 
HAVING COUNT(*) > 1;

-- Q-1 Build a country Map Table -- Create the Table 
Create Table Country_Map (
CountryCode INT Primary Key,
CountryName VARCHAR(100)
);
Insert into Country_Map (CountryCode,CountryName) values -- To insert the Values of Country Code and Country Name in the Table
(1, 'India'),
(14, 'Australia'),
(30, 'Brazil'),
(37, 'Canada'),
(94, 'Indonesia'),
(148, 'New Zealand'),
(162, 'Philippines'),
(166, 'Qatar'),
(184, 'Singapore'),
(189, 'South Africa'),
(191, 'Sri Lanka'),
(208, 'Turkey'),
(214, 'UAE'),
(215, 'United Kingdom'),
(216, 'United States');
select * from Country_Map;                  -- To check the Table
select distinct CountryCode                 -- To remove the duplicate results /rows in the result table and get the unique values.
FROM zomato_full;

select z.RestaurantID,z.RestaurantName,z.CountryCode,z.City,countryname from zomato_full z
LEFT JOIN Country_Map c on z.countrycode = c.countrycode;

 -- Q-2 Build a Calendar Table using the Column Datekey.Add all the below Columns in the Calendar Table using the Formulas.
Create table Calender(
Date date Primary key,
Year int,
Monthno int,
Monthfullname VARCHAR(50),
Quarter VARCHAR(5),
YearMonth varchar(20),
WeekdayNo int,
WeekdayName varchar(20),
FinancialMonth varchar(5),
FinancialQuarter VARCHAR(3)
);
Insert into Calender (Date)
Select distinct str_to_date
(Replace(TRIM(Datekey_Opening),'_','-'),'%Y-%c-%e')
from zomato_full 
where Datekey_Opening IS NOT NULL;

-- a) Add Year
set sql_safe_updates= 0;
update Calender SET year = year(Date)
where date IS NOT NULL;

-- b) Add Month Number
update Calender SET MONTHNO= month(Date);

-- c) Add Month Full Name
Update Calender set MONTHFULLNAME= monthname(Date);

-- d) Add Quarter
Update Calender set Quarter = concat("Q", Quarter(Date));

-- e) Add Year Month
Update Calender set YearMonth = date_format(Date,'%Y-%b');

-- f) Add Weekday no
Update Calender set WeekdayNo = weekday(Date) +1;   

-- g) Add Weekday Name
Update Calender set WeekdayName= dayname(Date); 

-- h)Financial Month
set sql_safe_updates= 0;
Alter Table zomato_full Add Column Financial_Month VARCHAR(20);
Update zomato_full set Datekey_Opening = STR_TO_DATE(Datekey_Opening, '%Y_%m_%d')
where Datekey_Opening IS NOT NULL;

-- i) Financial Quarter
describe zomato_full;
Alter Table zomato_full Add Column Financial_Quarter VARCHAR(10);
UPDATE zomato_full SET Financial_Quarter = concat('FQ',CEIL((MOD(MONTH(Datekey_Opening) - 4 + 12, 12) + 1) / 3))
where Datekey_Opening IS NOT NULL;

-- Q-3 Find the Numbers of Restaurants based on City and Country.
select CountryCode, City ,count(RestaurantID) as Number_of_Restaurants
from zomato_full 
group by City, CountryCode
Order By Number_of_Restaurants DESC;

-- Q-4 Find the Numbers of Restaurants opening based on Year, Quarter, Month
-- Answer 4(A)
select year(Datekey_Opening) AS year, Count(RestaurantID) as  Number_of_Restaurants
from zomato_full
Group By year(Datekey_Opening)
Order By Year;

-- Answer 4(B)
select quarter(Datekey_Opening) AS Quarter, Count(RestaurantID) as  Number_of_Restaurants
from zomato_full
Group By quarter(Datekey_Opening)
order by Quarter;

-- Answer 4(C)
select month(datekey_opening) as Month_Number, monthname(Datekey_Opening) AS Month_Name, Count(RestaurantID) as  Number_of_Restaurants
from zomato_full
Group By Month_Number, monthname(Datekey_Opening)
order by MONTH_Number;


-- Q-5 Count of Restaurants based on Average Ratings
select Rating , Count(RestaurantID) as  Number_of_Restaurants
from zomato_full
group by Rating
order By Rating ASC;

-- Q-6 Create buckets based on Average Price of reasonable size and find out how many restaurants falls in each bucket
Select CASE WHEN Average_Cost_for_two <=500
			THEN '0-500'
WHEN Average_Cost_for_two <= 1000
            THEN '501-1000'
WHEN Average_Cost_for_two <= 2000
            THEN '1001-2000'
WHEN Average_Cost_for_two <= 3000
            THEN '2001-3000'
ELSE '3001+'
    END AS Average_Cost_for_two,
    Count(RestaurantID) as Number_of_Restaurants
  From  zomato_full
  Group By Case WHEN Average_Cost_for_two <=500
			THEN '0-500'
  WHEN Average_Cost_for_two <= 1000
            THEN '501-1000'
  WHEN Average_Cost_for_two <= 2000
            THEN '1001-2000'    
  WHEN Average_Cost_for_two <= 3000
            THEN '2001-3000'
   ELSE '3001+'
   END 
  Order By MIN(Average_Cost_for_two);
  
-- Q-7 Percentage of Restaurants Based on Has_Table_booking
SELECT Has_Table_booking ,count(RestaurantID) as Number_of_Restaurants,
 ROUND (COUNT(RestaurantID) * 100.0 /
 (SELECT COUNT(*) FROM zomato_full),
        2  ) AS Percentage
      FROM zomato_full
	  GROUP BY Has_Table_booking;
 
-- Q-8 Percentage of Restaurants Based on Has_Online_Delivery
SELECT Has_Online_Delivery ,count(RestaurantID) as Number_of_Restaurants,
 ROUND (COUNT(RestaurantID) * 100.0 /
 (SELECT COUNT(*) FROM zomato_full),
        2  ) AS Percentage
      FROM zomato_full
	  GROUP BY Has_Online_Delivery;
      
-- Q-9a) Restaurants by Cuisine 
select Cuisines, COUNT(RestaurantID) AS Number_of_Restaurants
from zomato_full
group by Cuisines
order by Number_of_Restaurants DESC;

-- Q-9B) Restaurants by city
select City, COUNT(RestaurantID) AS Number_of_Restaurants
from zomato_full
group by City
order by Number_of_Restaurants DESC;

-- Q-9C) Restaurants by Ratings 
select Rating, count(RestaurantID) AS Number_of_Restaurants
from zomato_full
group by rating
order by rating DESC;


-- Q-10) KPIS 
-- KPI 1 — Total Restaurants
Select count(RestaurantID) AS Total_Restaurants
From zomato_full;

-- KPI 2 — Average Rating
SELECT
    ROUND(AVG(Rating), 2) AS Average_Rating
FROM zomato_full;

-- KPI 3 - Average cost for two
select
  round(Avg(Average_Cost_for_two), 2) AS Average_Cost_for_Two
  FROM zomato_full;
  
-- KPI 4- Total Cities
Select count(Distinct city) as Total_Cities
FROM zomato_full;

-- KPI 5 — Online Delivery Percentage
Select 
    ROUND(
    
        SUM(Has_Online_delivery = 'Yes') * 100.0 /
        COUNT(*),
        2
    ) AS Online_Delivery_Percentage
FROM zomato_full;

-- KPI 6 - Table Booking Percentage
Select 
round(
		Sum(Has_Table_booking ='Yes')*100.0 /
        COUNT(*),
        2) AS TABLE_BOOKING
   FROM zomato_full;     

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Roll-ups
-- Q-3 Restaurants by Country and City
SELECT
    COALESCE(CountryCode, 'GRAND TOTAL') AS CountryCode,
    COALESCE(City, 'COUNTRY TOTAL') AS City,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM zomato_full
GROUP BY CountryCode, City WITH ROLLUP
ORDER BY CountryCode, City;
-------------------------------------------------------------------------------------------------------------------



-- Q-4 Find the Number of Restaurants Opening based on Year, Quarter and Month
SELECT
    YEAR(Datekey_Opening) AS Opening_Year,
    QUARTER(Datekey_Opening) AS Opening_Quarter,
    MONTH(Datekey_Opening) AS Opening_Month,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM zomato_full
WHERE Datekey_Opening IS NOT NULL
GROUP BY
    YEAR(Datekey_Opening),
    QUARTER(Datekey_Opening),
    MONTH(Datekey_Opening)
WITH ROLLUP;
------------------------------------------------------------------------------------------------------------------
-- Q-5 Count of Restaurants based on Average Ratings
SELECT
    COALESCE(CAST(Rating AS CHAR), 'GRAND TOTAL') AS Rating,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM zomato_full
GROUP BY Rating WITH ROLLUP
ORDER BY Rating;
------------------------------------------------------------------------------------------------------------------
-- Q-6 Restaurants by Average Cost Bucket
SELECT
    COALESCE(Average_Cost_Bucket, 'GRAND TOTAL') AS Average_Cost_Bucket,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM
(SELECT RestaurantID,
        CASE
            WHEN Average_Cost_for_two <= 500 THEN '0-500'
            WHEN Average_Cost_for_two <= 1000 THEN '501-1000'
            WHEN Average_Cost_for_two <= 2000 THEN '1001-2000'
            WHEN Average_Cost_for_two <= 3000 THEN '2001-3000'
            ELSE '3001+'
        END AS Average_Cost_Bucket FROM zomato_full
) AS Cost_Buckets
GROUP BY Average_Cost_Bucket WITH ROLLUP;
 -----------------------------------------------------------------------------------------------------------------
 -- Q-7 Percentage of Restaurants Based on Has_Table_booking
 SELECT
    COALESCE(Has_Table_booking, 'GRAND TOTAL') AS Has_Table_Booking,
    COUNT(RestaurantID) AS Number_of_Restaurants,
    ROUND(
        COUNT(RestaurantID) * 100.0 /
        (SELECT COUNT(*) FROM zomato_full),
        2
    ) AS Percentage
FROM zomato_full
GROUP BY Has_Table_booking WITH ROLLUP;
------------------------------------------------------------------------------------------------------------------
-- Q-8 Percentage of Restaurants Based on Has_Online_Delivery
SELECT
    COALESCE(Has_Online_Delivery, 'GRAND TOTAL') AS Has_Online_Delivery,
    COUNT(RestaurantID) AS Number_of_Restaurants,
    ROUND(
        COUNT(RestaurantID) * 100.0 /
        (SELECT COUNT(*) FROM zomato_full),
        2
    ) AS Percentage
FROM zomato_full
GROUP BY Has_Online_Delivery WITH ROLLUP;
------------------------------------------------------------------------------------------------------------------
-- Q-9A Restaurants by Cuisine
SELECT
    COALESCE(Cuisines, 'GRAND TOTAL') AS Cuisines,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM zomato_full
GROUP BY Cuisines WITH ROLLUP
ORDER BY
    CASE WHEN Cuisines IS NULL THEN 1 ELSE 0 END,
    Number_of_Restaurants DESC;
-----------------------------------------------------------------------------------------------------------------
-- Q-9B Restaurants by City
SELECT
    COALESCE(City, 'GRAND TOTAL') AS City,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM zomato_full
GROUP BY City WITH ROLLUP
ORDER BY
    CASE WHEN City IS NULL THEN 1 ELSE 0 END,
    Number_of_Restaurants DESC;
---------------------------------------------------------------------------------------------------------------
















-- Q-9C Restaurants by Ratings
SELECT
    COALESCE(CAST(Rating AS CHAR), 'GRAND TOTAL') AS Rating,
    COUNT(RestaurantID) AS Number_of_Restaurants
FROM zomato_full
GROUP BY Rating WITH ROLLUP
ORDER BY
    CASE WHEN Rating IS NULL THEN 1 ELSE 0 END,
    Rating DESC;