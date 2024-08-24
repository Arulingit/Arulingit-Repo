


use database NUCOR_PRODREP;
use schema Revenue_report_Manager;
ALTER TABLE NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE
ALTER COLUMN ProfitMargin SET DATA TYPE NUMBER(6,2);

truncate table NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDCUSTOMERINSIGHTS
truncate table  NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE

-- Call the procedure to load data
CALL load_transformed_data_CUSTOMERs();

truncate table DimDate;

select count(*) from NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDCUSTOMERINSIGHTS limit 10;
select count(*) from NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE limit 10;


CREATE OR REPLACE TASK Load_DimDate
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON 0 */3 * * * UTC'
--SCHEDULE = 'USING CRON */10 * * * * UTC'
AS
INSERT INTO DimDate (DateKey, Year, Quarter, Month, Day)
SELECT DISTINCT 
    RevenueDate AS DateKey, 
    YEAR(RevenueDate) AS Year, 
    QUARTER(RevenueDate) AS Quarter, 
    MONTH(RevenueDate) AS Month, 
    DAY(RevenueDate) AS Day
FROM NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE
WHERE RevenueDate IS NOT NULL limit 10;

CREATE OR REPLACE TASK Load_DimCustomer
WAREHOUSE = COMPUTE_WH
AFTER Load_DimDate
AS
INSERT INTO DimCustomer (CustomerID, CustomerName, CustomerSegment)
SELECT DISTINCT 
    CustomerID, 
    -- Assuming CustomerName and CustomerSegment are columns in the source table
    'Unknown' AS CustomerName,  -- Placeholder or default value
    'Unknown' AS CustomerSegment  -- Placeholder or default value
FROM NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TransformedCustomerInsights;


CREATE OR REPLACE TASK Load_DimCustomer
WAREHOUSE = COMPUTE_WH
AFTER Load_DimDate
AS
INSERT INTO DimCustomer (CustomerID, CustomerName, CustomerSegment)
SELECT DISTINCT 
    CustomerID, 
    -- Assuming CustomerName and CustomerSegment are columns in the source table
    'Unknown' AS CustomerName,  -- Placeholder or default value
    'Unknown' AS CustomerSegment  -- Placeholder or default value
FROM NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TransformedCustomerInsights;



CREATE OR REPLACE TASK  Load_FactCustomerInsights
WAREHOUSE = COMPUTE_WH
AFTER Load_DimCustomer
AS
INSERT INTO FactCustomerInsights
SELECT 
    tci.CustomerID, 
    dd.DateKey,
    tci.SatisfactionScore,
    tci.TotalPurchases
FROM TransformedCustomerInsights tci
JOIN DimDate dd ON tci.LastPurchaseDate = dd.DateKey  limit 10;



CREATE OR REPLACE TASK Load_FactRevenue
WAREHOUSE = COMPUTE_WH
AFTER Load_DimDate
AS
INSERT INTO FactRevenue
SELECT 
    tr.RevenueDate, 
    tr.TotalRevenue, 
    tr.CostOfGoodsSold, 
    tr.ProfitMargin
FROM TransformedRevenue tr
JOIN DimDate dd ON tr.RevenueDate = dd.DateKey limit 10;


ALTER TASK Load_DimDate RESUME;
ALTER TASK Load_DimCustomer RESUME;
ALTER TASK Load_FactCustomerInsights RESUME;
ALTER TASK Load_FactRevenue RESUME;

ALTER TASK Load_DimDate SUSPEND;
ALTER TASK Load_DimCustomer SUSPEND;
ALTER TASK Load_FactCustomerInsights SUSPEND;
ALTER TASK Load_FactRevenue SUSPEND;

select * from DimDate;
select * from FactRevenue;
select * from DimCustomer;
select * from FactCustomerInsights;

select * from NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE limit 2;
select * from NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDCUSTOMERINSIGHTS limit 2;

truncate table DimDate;
truncate table DimCustomer;
truncate table FactRevenue;
truncate tableFactCustomerInsights;
