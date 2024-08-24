CREATE OR REPLACE PROCEDURE load_raw_customer_data()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
var record_count = 200; // Number of records to load

try {
    for (var i = 1; i <= record_count; i++) {
        // Construct the dynamic JSON data
        var json_data = {
            CustomerID: `CUST${i}`,
            SatisfactionScore: Math.floor(Math.random() * 10) + 1,
            Feedback: `Feedback ${i}`,
            TotalPurchases: Math.floor(Math.random() * 100) + 1,
            LastPurchaseDate: `2024-08-${(i % 31) + 1}`
        };

        // Convert JSON object to string
        var json_string = JSON.stringify(json_data);

        // Construct the SQL command with direct JSON string parsing
        var sql_command = `
            INSERT INTO RawCustomerData (json_data)
            SELECT PARSE_JSON('${json_string.replace(/'/g, "''")}')
        `;

        // Execute the SQL command
        snowflake.execute({
            sqlText: sql_command
        });
    }

    return 'Data loaded successfully';
} catch (err) {
    return `Error loading data: ${err.message}`;
}
$$;


-- Call the procedure to load data
CALL load_raw_customer_data();

