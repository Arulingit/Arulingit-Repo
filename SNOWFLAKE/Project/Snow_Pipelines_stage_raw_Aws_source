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
create or replace file format csv_load_format
type='CSV'
compression='AUTO'
field_delimiter=','
record_delimiter='\n'
skip_header=1
field_optionally_enclosed_by='\042'
trim_space=FALSE
error_on_column_count_mismatch=TRUE
escape='NONE'
escape_unenclosed_field='\134'
date_format='AUTO'
timestamp_format='AUTO';

create or replace stage Aws_Snowflake_csv
storage_integration=aws_snf_data                                                                
url='s3://01loaddatatosnowflake/csv'
file_format=csv_load_format;
list @stage_csv_file




CREATE OR REPLACE TABLE RawRevenueData_csv (
    RevenueID STRING,
    RevenueDate DATE,
    TotalRevenue DECIMAL(10,2),
    CostOfGoodsSold DECIMAL(10,2),
    ProfitMargin DECIMAL(10,2)
);




select * from RawRevenueData_csv
truncate table RawRevenueData_csv;

CREATE OR REPLACE PIPE SNOWPIPELINE_2_AWS_S3 AUTO_INGEST=TRUE 
 AS
 COPY INTO RawRevenueData_csv  FROM @Aws_Snowflake_csv FILE_FORMAT = (TYPE = 'CSV') ON_ERROR=continue;;


           

--OFFLOAD



COPY INTO @Aws_Snowflake_csv/revenue_data.csv
FROM RawRevenueData_csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');

