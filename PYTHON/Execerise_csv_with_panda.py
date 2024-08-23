##Learning to use panda for excel -commting first
import pandas as pd
from datetime import datetime
# Load the Excel file
excel_file = r'C:\Users\akubendran\AWS\T01.xlsx'.replace('\\', '/')
df = pd.read_excel(excel_file)

#Decode
df_unique=df.drop_duplicates()
df_duplicate=df[df.duplicated(keep=False)]

#transform



#report
print("totalrows:",len(df))
print("df_uniquetotalrows:",len(df_unique))
print("df_df_duplicatetotalrows:",len(df_duplicate))
print (df_duplicate)
