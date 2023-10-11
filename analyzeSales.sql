-- Exploring Internet Sales Data

SELECT date.CalendarYear as Year,
        SUM(sales.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS sales 
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
GROUP BY date.CalendarYear
ORDER BY Year;


SELECT date.CalendarYear as Year,
        date.MonthNumberOfYear AS Month,
        SUM(sales.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS sales 
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
GROUP BY date.CalendarYear, date.MonthNumberOfYear
ORDER BY Year, Month;


-- Show yearly internet sales totals for each region
SELECT date.CalendarYear as Year,
        geo.EnglishCountryRegionName AS Region,
        SUM(sales.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS sales 
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
JOIN DimCustomer AS cus ON sales.CustomerKey = cus.CustomerKey
JOIN DimGeography AS geo ON cus.GeographyKey = geo.GeographyKey
GROUP BY date.CalendarYear, geo.EnglishCountryRegionName
ORDER BY Year, Region;


-- Aggregate the yearly regional sales by product category
SELECT date.CalendarYear as Year,
        pc.EnglishProductCategoryName AS ProductCategory,
        geo.EnglishCountryRegionName AS Region,
        SUM(sales.SalesAmount) AS InternetSalesAmount
FROM FactInternetSales AS sales 
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
JOIN DimCustomer AS cus ON sales.CustomerKey = cus.CustomerKey
JOIN DimGeography AS geo ON cus.GeographyKey = geo.GeographyKey
JOIN DimProduct AS prod ON sales.ProductKey = prod.ProductKey
JOIN DimProductSubcategory AS psc ON prod.ProductSubcategoryKey = psc.ProductSubcategoryKey
JOIN DimProductCategory AS pc ON psc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY date.CalendarYear, pc.EnglishProductCategoryName, geo.EnglishCountryRegionName
ORDER BY Year, ProductCategory, Region;


-- Using ranking functions
-- Retrieve sales value for 2022 over partition based on country/region
SELECT geo.EnglishCountryRegionName AS Region,
        ROW_NUMBER() OVER(PARTITION BY geo.EnglishCountryRegionName
                        ORDER BY sales.SalesAmount ASC) AS RowNumber,
        sales.SalesOrderNumber AS OrderNo,
        sales.SalesOrderLineNumber AS LineItem,
        sales.SalesAmount AS SalesAmount,
        SUM(sales.SalesAmount) OVER(PARTITION BY geo.EnglishCountryRegionName) AS RegionTotal,
        AVG(sales.SalesAmount) OVER(PARTITION BY geo.EnglishCountryRegionName) AS RegionAverage
FROM FactInternetSales AS sales 
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
JOIN DimCustomer AS cus ON sales.CustomerKey = cus.CustomerKey
JOIN DimGeography AS geo ON cus.GeographyKey = geo.GeographyKey
WHERE date.CalendarYear = 2022
ORDER BY Region;

--
SELECT geo.EnglishCountryRegionName AS Region,
        geo.City,
        SUM(sales.SalesAmount) AS CityTotal,
        SUM(SUM(sales.SalesAmount)) OVER(PARTITION BY geo.EnglishCountryRegionName) AS RegionTotal,
        RANK() OVER(PARTITION BY geo.EnglishCountryRegionName
                        ORDER BY SUM(sales.SalesAmount) DESC) AS RegionalRank
FROM FactInternetSales AS sales 
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
JOIN DimCustomer AS cus ON sales.CustomerKey = cus.CustomerKey
JOIN DimGeography AS geo ON cus.GeographyKey = geo.GeographyKey
GROUP BY geo.EnglishCountryRegionName, geo.City
ORDER BY Region;


-- Count the number of sales orders for each calendar year
SELECT date.CalendarYear AS CalendarYear,
        COUNT(DISTINCT sales.SalesOrderNumber) AS Orders
FROM FactInternetSales AS sales
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
GROUP BY date.CalendarYear
ORDER BY CalendarYear;


SELECT date.CalendarYear AS CalendarYear,
        APPROX_COUNT_DISTINCT(sales.SalesOrderNumber) AS Orders
FROM FactInternetSales AS sales
JOIN DimDate AS date ON sales.OrderDateKey = date.DateKey
GROUP BY date.CalendarYear
ORDER BY CalendarYear;



