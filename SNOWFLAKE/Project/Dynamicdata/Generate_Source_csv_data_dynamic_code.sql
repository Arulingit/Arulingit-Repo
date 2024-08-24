
-- Generate and insert random data
CREATE OR REPLACE PROCEDURE generate_random_data()
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
var record_count = 200; // Number of records to generate
var sql_command;
var revenue_id, revenue_date, total_revenue, cost_of_goods_sold, profit_margin;

try {
    for (var i = 1; i <= record_count; i++) {
        // Generate random data
        revenue_id = 'REV' + i;
        revenue_date = '2024-08-' + (i % 31 + 1);
        total_revenue = (Math.random() * 10000).toFixed(2);
        cost_of_goods_sold = (Math.random() * 5000).toFixed(2);
        profit_margin = (Math.random() * 100).toFixed(2);

        // Construct the SQL command
        sql_command = `
            INSERT INTO RawRevenueData_csv (RevenueID, RevenueDate, TotalRevenue, CostOfGoodsSold, ProfitMargin)
            VALUES ('${revenue_id}', '${revenue_date}', ${total_revenue}, ${cost_of_goods_sold}, ${profit_margin});
        `;

        // Execute the SQL command
        snowflake.execute({
            sqlText: sql_command
        });
    }

    return 'Data generated successfully';
} catch (err) {
    return `Error generating data: ${err.message}`;
}
$$;


CALL generate_random_data();
