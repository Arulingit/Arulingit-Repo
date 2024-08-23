

CREATE TABLE TransformedRevenue (
    RevenueDate DATE,
    TotalRevenue DECIMAL(15,2),
    CostOfGoodsSold DECIMAL(15,2),
    ProfitMargin DECIMAL(5,2)
);


CREATE TABLE TransformedCustomerInsights (
    CustomerID VARCHAR(50),
    SatisfactionScore INT,
    Feedback TEXT,
    TotalPurchases INT,
    LastPurchaseDate DATE
);



CREATE TABLE DimDate (
    DateKey DATE PRIMARY KEY,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT
);


CREATE TABLE DimCustomer (
    CustomerID VARCHAR(50) PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerSegment VARCHAR(50)
);


CREATE TABLE FactRevenue (
    RevenueDate DATE REFERENCES DimDate(DateKey),
    TotalRevenue DECIMAL(15,2),
    CostOfGoodsSold DECIMAL(15,2),
    ProfitMargin DECIMAL(5,2)
);



CREATE TABLE FactCustomerInsights (
    CustomerID VARCHAR(50) REFERENCES DimCustomer(CustomerID),
    DateKey DATE REFERENCES DimDate(DateKey),
    SatisfactionScore INT,
    TotalPurchases INT
);




ALTER TABLE NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE
ALTER COLUMN ProfitMargin SET DATA TYPE NUMBER(6,2);

use database NUCOR_PRODREP;
use schema Revenue_report_Manager;
ALTER TABLE NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE
ALTER COLUMN ProfitMargin SET DATA TYPE NUMBER(6,2);
-- Create a stored procedure to dynamically load data
-- Sample SQL to create 500 records
CREATE OR REPLACE PROCEDURE load_transformed_data_Revenue()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER
AS
$$
  var record_count = 500; // Set the number of records to load
  var sql_command;
  var revenueDate, totalRevenue, costOfGoodsSold, profitMargin;

  for (var i = 0; i < record_count; i++) {
    // Generate random data
    revenueDate = new Date(Date.now() - Math.floor(Math.random() * 365 * 24 * 60 * 60 * 1000)); // Random date within last year
    totalRevenue = (Math.random() * 100000).toFixed(2); // Random revenue between 0 and 100,000
    costOfGoodsSold = (Math.random() * 50000).toFixed(2); // Random COGS between 0 and 50,000
    profitMargin = ((totalRevenue - costOfGoodsSold) / totalRevenue * 100).toFixed(2); // Calculate profit margin

    // Construct the dynamic SQL command
    sql_command = `INSERT INTO NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE
                   (RevenueDate, TotalRevenue, CostOfGoodsSold, ProfitMargin)
                   VALUES ('${revenueDate.toISOString().split('T')[0]}', ${totalRevenue}, ${costOfGoodsSold}, ${profitMargin})`;

    // Execute the SQL command
    snowflake.execute({sqlText: sql_command});
  }
  return 'Data loaded successfully';
$$;



-- Call the procedure to load data
CALL load_transformed_data_Revenue();

use database NUCOR_PRODREP;
use schema Revenue_report_Manager;

-- Create a stored procedure to dynamically load data
CREATE OR REPLACE PROCEDURE load_transformed_data_CUSTOMERs()
  RETURNS STRING
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER
AS
$$
  var record_count = 500; // Set the number of records to load
  var sql_command;
  var customerID;

  for (var i = 0; i < record_count; i++) {
    // Generate a unique CustomerID
    customerID = 'CUST' + (i + 1).toString().padStart(3, '0');
    
    // Generate random data for other columns
    var satisfactionScore = (Math.random() * 10).toFixed(1);  // Random score between 0.0 and 10.0
    var feedbacks = ['Great service!', 'Good experience', 'Exceeded expectations', 'Average service', 'Very satisfied'];
    var feedback = feedbacks[Math.floor(Math.random() * feedbacks.length)];
    var totalPurchases = Math.floor(Math.random() * 10) + 1;  // Random number between 1 and 10
    var lastPurchaseDate = new Date(Date.now() - Math.floor(Math.random() * 365 * 24 * 60 * 60 * 1000));  // Random date within last year

    // Construct the dynamic SQL command
    sql_command = `INSERT INTO NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDCUSTOMERINSIGHTS 
                   (CustomerID, SatisfactionScore, Feedback, TotalPurchases, LastPurchaseDate)
                   VALUES ('${customerID}', ${satisfactionScore}, '${feedback}', ${totalPurchases}, '${lastPurchaseDate.toISOString().split('T')[0]}')`;

    // Execute the SQL command
    snowflake.execute({sqlText: sql_command});
  }
  return 'Data loaded successfully';
$$;

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
