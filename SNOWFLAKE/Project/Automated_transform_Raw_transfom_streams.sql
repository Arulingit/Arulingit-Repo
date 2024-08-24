use role accountadmin;
use database NUCOR_PRODREP;
use schema Revenue_report_Manager;


CREATE OR REPLACE TABLE TransformedRevenue (
    RevenueMonth STRING,
    TotalRevenue DECIMAL(10,2),
    TotalCost DECIMAL(10,2),
    TotalProfit DECIMAL(10,2)
);

INSERT INTO TransformedRevenue
SELECT
    RevenueDate,
    SUM(TotalRevenue) AS TotalRevenue,
    SUM(CostOfGoodsSold) AS CostOfGoodsSold,
    (SUM(TotalRevenue) - SUM(CostOfGoodsSold)) / NULLIF(SUM(TotalRevenue), 0) AS ProfitMargin
FROM RawRevenueData_csv
GROUP BY RevenueDate;


CREATE OR REPLACE STREAM raw_revenue_stream ON TABLE RawRevenueData_csv;
CREATE OR REPLACE STREAM raw_customer_stream ON TABLE RAWCUSTOMERDATA_JSON;

show warehouses
CREATE OR REPLACE TASK transform_revenue_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = '10 MINUTE'
AS
INSERT INTO TransformedRevenue
SELECT
    r.RevenueDate,  -- Specify the alias for RevenueDate
    SUM(r.TotalRevenue) AS TotalRevenue,
    SUM(r.CostOfGoodsSold) AS CostOfGoodsSold,
    (SUM(r.TotalRevenue) - SUM(r.CostOfGoodsSold)) / NULLIF(SUM(r.TotalRevenue), 0) AS ProfitMargin
FROM RawRevenueData_csv r  -- Alias for RawRevenueData_csv
JOIN raw_revenue_stream s  -- Alias for raw_revenue_stream
ON r.RevenueID = s.RevenueID
GROUP BY r.RevenueDate;  -- Use the alias for RevenueDate in GROUP BY


CREATE OR REPLACE TASK transform_customer_task
WAREHOUSE = COMPUTE_WH
SCHEDULE = '10 MINUTE'
AS
INSERT INTO TransformedCustomerInsights
SELECT
    CustomerID,
    SatisfactionScore,
    Feedback,
    TotalPurchases,
    LastPurchaseDate
FROM RAWCUSTOMERDATA_JSON
JOIN raw_customer_stream ON RawCustomerData.CustomerID = raw_customer_stream.CustomerID
WHERE raw_customer_stream.metadata$action = 'INSERT' OR raw_customer_stream.metadata$action = 'UPDATE';
