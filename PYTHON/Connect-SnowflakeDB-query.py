import snowflake.connector

ctx = snowflake.connector.connect(
    user='arulinsnf',
    password='**********$2025',
    account='NGB28913',
    region='us-east-1',
    warehouse="compute_wh",
    database="ecommerce_db",
    schema="ECOMMERCE_LIV",
    role='ACCOUNTADMIN')

cs = ctx.cursor()
try:
    sql = """select * from LINEITEM  limit 10"""
    cs.execute(sql)
    # one_row = cs.fetchone()
    all_rows = cs.fetchall()
    # print(one_row[0])
    print(all_rows)

finally:
    cs.close()
ctx.close()
