use role accountadmin;
use database NUCOR_PRODREP;
use schema Revenue_report_Manager;



create or replace storage integration aws_snf_data
type=external_stage
storage_provider=s3
enabled=true
storage_aws_role_arn='arn:aws:iam::876809972236:role/Welcomeguest'
storage_allowed_locations=('s3://01loaddatatosnowflake/');

desc integration aws_snf_data


create or replace stage Aws_Snowflake_csv
storage_integration=aws_snf_data                                                                
url='s3://01loaddatatosnowflake/csv'
file_format=csv_load_format;
list @Aws_Snowflake_csv




CREATE OR REPLACE TABLE RawRevenueData_csv (
    RevenueID STRING,
    RevenueDate DATE,
    TotalRevenue DECIMAL(10,2),
    CostOfGoodsSold DECIMAL(10,2),
    ProfitMargin DECIMAL(10,2)
);
CREATE OR REPLACE FILE FORMAT csv_load_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1
  NULL_IF = ('')
  EMPTY_FIELD_AS_NULL = TRUE
  DATE_FORMAT = 'AUTO'
  TIMESTAMP_FORMAT = 'AUTO';


list @Aws_Snowflake_csv;


select * from RawRevenueData_csv
truncate table RawRevenueData_csv;

CREATE OR REPLACE PIPE SNOWPIPELINE_2_AWS_S3 
AUTO_INGEST = TRUE 
AS
COPY INTO RawRevenueData_csv 
FROM @Aws_Snowflake_csv
FILE_FORMAT = (TYPE = 'CSV') 
ON_ERROR = 'CONTINUE';
SELECT * FROM TABLE(information_schema.query_history())
WHERE query_text ILIKE '%COPY INTO%';

show pipes

    ALTER PIPE SNOWPIPELINE_2_AWS_S3 SET PIPE_EXECUTION_PAUSED = TRUE;
ALTER PIPE SNOWPIPELINE_2_AWS_S3 SET PIPE_EXECUTION_PAUSED = FALSE;
ALTER PIPE SNOWPIPELINE_2_AWS_S3  REFRESH;       

--OFFLOAD



COPY INTO @Aws_Snowflake_csv/revenue_data.csv
FROM RawRevenueData_csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');

