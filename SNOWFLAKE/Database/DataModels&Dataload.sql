

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





CREATE OR REPLACE TASK Load_DimDate
WAREHOUSE = COMPUTE_WH
SCHEDULE = 'USING CRON */10 * * * * UTC'
AS
INSERT INTO DimDate (DateKey, Year, Quarter, Month, Day)
SELECT DISTINCT 
    RevenueDate AS DateKey, 
    YEAR(RevenueDate) AS Year, 
    QUARTER(RevenueDate) AS Quarter, 
    MONTH(RevenueDate) AS Month, 
    DAY(RevenueDate) AS Day
FROM NUCOR_PRODREP.REVENUE_REPORT_MANAGER.TRANSFORMEDREVENUE
WHERE RevenueDate IS NOT NULL;



CREATE TASK Load_FactCustomerInsights
WAREHOUSE = my_warehouse
AFTER Load_DimCustomer
AS
INSERT INTO FactCustomerInsights
SELECT 
    tci.CustomerID, 
    dd.DateKey,
    tci.SatisfactionScore,
    tci.TotalPurchases
FROM TransformedCustomerInsights tci
JOIN DimDate dd ON tci.LastPurchaseDate = dd.DateKey;

CREATE TASK Load_FactRevenue
WAREHOUSE = my_warehouse
AFTER Load_DimDate
AS
INSERT INTO FactRevenue
SELECT 
    tr.RevenueDate, 
    tr.TotalRevenue, 
    tr.CostOfGoodsSold, 
    tr.ProfitMargin
FROM TransformedRevenue tr
JOIN DimDate dd ON tr.RevenueDate = dd.DateKey;


CREATE TASK Load_FactCustomerInsights
WAREHOUSE = my_warehouse
AFTER Load_DimCustomer
AS
INSERT INTO FactCustomerInsights
SELECT 
    tci.CustomerID, 
    dd.DateKey,
    tci.SatisfactionScore,
    tci.TotalPurchases
FROM TransformedCustomerInsights tci
JOIN DimDate dd ON tci.LastPurchaseDate = dd.DateKey;














