
----1 cumulative sales
WITH SalespersonPerformance AS (
    SELECT 
        CASE 
            WHEN sales.SalesPersonID IS NULL THEN 'Online'
            ELSE CAST(sales.SalesPersonID AS STRING)
        END AS SalesPersonNew,
        SUM(sales.TotalDue) AS SumSales
    FROM 
        `adwentureworks_db.salesorderheader` AS sales
    GROUP BY 
        SalesPersonNew
),
RankedSales AS (
    SELECT 
        SalesPersonNew,
        SumSales,
        SUM(SumSales) OVER (ORDER BY SumSales DESC) AS CumulativeTotal,
        ROW_NUMBER() OVER (ORDER BY SumSales DESC) AS Ranking
    FROM 
        SalespersonPerformance
)
SELECT 
    RankedSales.SalesPersonNew,
    RankedSales.SumSales,
    RankedSales.CumulativeTotal,
    (SELECT SUM(SumSales) FROM SalespersonPerformance) AS TotalSales,
    RankedSales.CumulativeTotal / (SELECT SUM(SumSales) FROM SalespersonPerformance) AS CumulativePercent
FROM 
    RankedSales






----2 country
SELECT
    soh.OrderDate,
    COUNT(soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalSales,
    st.Group AS TerritoryGroup,
    st.Name AS SalesTerritory

FROM
    `adwentureworks_db.salesorderheader` AS soh

LEFT JOIN
    `adwentureworks_db.salesterritory` AS st ON soh.TerritoryID = st.TerritoryID

WHERE soh.OrderDate IS NOT NULL

GROUP BY
    soh.OrderDate,
    st.Group,
    st.Name

ORDER BY
    soh.OrderDate,
    st.Name;






----3 sales reason
WITH sales_per_reason AS (
 SELECT
   DATE_TRUNC(OrderDate, MONTH) AS year_month,
   sales_reason.SalesReasonID,
   SUM(sales.TotalDue) AS sales_amount

 FROM
   `tc-da-1.adwentureworks_db.salesorderheader` AS sales

JOIN `tc-da-1.adwentureworks_db.salesorderheadersalesreason` AS sales_reason
    ON sales.SalesOrderID = sales_reason.salesOrderID
    
 GROUP BY 1,2
)
SELECT
 sales_per_reason.year_month,
 reason.Name AS sales_reason,
 sales_per_reason.sales_amount

FROM sales_per_reason

LEFT JOIN `tc-da-1.adwentureworks_db.salesreason` AS reason
    ON sales_per_reason.SalesReasonID = reason.SalesReasonID






----4 Geo
SELECT
      salesorderheader.*,
      province.stateprovincecode as ship_province,
      province.CountryRegionCode as country_code,
      province.name as country_state_name

FROM `tc-da-1.adwentureworks_db.salesorderheader` as salesorderheader

JOIN `tc-da-1.adwentureworks_db.address` as address
    ON salesorderheader.ShipToAddressID = address.AddressID

JOIN `tc-da-1.adwentureworks_db.stateprovince` as province
    ON address.stateprovinceid = province.stateprovinceid