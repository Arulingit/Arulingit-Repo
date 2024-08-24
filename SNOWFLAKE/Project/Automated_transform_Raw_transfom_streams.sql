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
SCHEDULE = '2 MINUTE'
AS
INSERT INTO TransformedCustomerInsights
sELECT
    raw_data.json_data:CustomerID::STRING AS CustomerID,
    raw_data.json_data:SatisfactionScore::INT AS SatisfactionScore,
    raw_data.json_data:Feedback::STRING AS Feedback,
    raw_data.json_data:TotalPurchases::INT AS TotalPurchases,
    raw_data.json_data:LastPurchaseDate::DATE AS LastPurchaseDate
FROM RAWCUSTOMERDATA_JSON AS raw_data
JOIN raw_customer_stream AS stream
    ON raw_data.json_data:CustomerID::STRING = stream.json_data:CustomerID::STRING
WHERE stream.METADATA$ACTION IN ('INSERT', 'UPDATE');

