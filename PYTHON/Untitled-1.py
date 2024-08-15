
import pandas as pd
from datetime import datetime

# Load the Excel file
excel_file = r'C:\Users\akubendran\Documents\NESSCAN_CTIS\T01.xlsx'.replace('\\', '/')
df = pd.read_excel(excel_file)
