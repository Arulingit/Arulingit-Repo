
CREATE OR REPLACE TABLE RawRevenueData (
    RevenueID STRING,
    RevenueDate DATE,
    TotalRevenue DECIMAL(10,2),
    CostOfGoodsSold DECIMAL(10,2),
    ProfitMargin DECIMAL(10,2)
);

CREATE OR REPLACE TABLE RawCustomerData (
    CustomerID STRING,
    SatisfactionScore INT,
    Feedback STRING,
    TotalPurchases INT,
    LastPurchaseDate DATE
);


CREATE OR REPLACE TABLE RawRevenueData_csv (
    RevenueID STRING,
    RevenueDate DATE,
    TotalRevenue DECIMAL(10,2),
    CostOfGoodsSold DECIMAL(10,2),
    ProfitMargin DECIMAL(10,2)
);


CREATE OR REPLACE TABLE RawCustomerData_json (
    CustomerID STRING,
    SatisfactionScore INT,
    Feedback STRING,
    TotalPurchases INT,
    LastPurchaseDate DATE
);
