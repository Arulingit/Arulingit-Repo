

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






CREATE TASK Load_DimDate
WAREHOUSE = my_warehouse
SCHEDULE = 'USING CRON 0 * * * * UTC'
AS
INSERT INTO DimDate
SELECT DISTINCT DateKey, Year(DateKey), Quarter(DateKey), Month(DateKey), Day(DateKey)
FROM TransformedRevenue;


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

