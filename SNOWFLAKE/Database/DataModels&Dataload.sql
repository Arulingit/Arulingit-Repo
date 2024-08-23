

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


