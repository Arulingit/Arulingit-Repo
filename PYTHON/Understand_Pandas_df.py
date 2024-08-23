import pandas as pd

data ={
    'Country':['India','India','UK','AUS','ARAB','NZ','India'],
    'Name':['Arul','Arul','Bob','Charlie','Doc','Bil','Maggie'],
    'Age':[40,41,25,30,40,25,30],
    'City':['NW','NW','CA','MD','NW','FL','NY'] 
}

df=pd.DataFrame(data)
print("Datframe:\n",df)
df_unique=df.drop_duplicates()
print ("\n de-depluicated1 \n",df_unique)

df_unique=df.drop_duplicates(subset=['Name'])


print ("\n de-depluicated_name \n",df_unique)


average_age=df['Age'].mean()
print ("\n Average age: ",average_age)


filtered_df=df[df['Age'] > 30]
print ("\n filtered by age in dataframe (age>30):\n",filtered_df)


max_age=df['Age'].max()
print("\n Max age:",max_age)
max_age=df['Age'].min()
print("\n min age:",max_age)

UP = df.apply(lambda x: x.str.upper() if x.dtype == "object" else x)

print("\n UP :",UP)

sort_df=df.sort_values(by='Age',ascending=False)
print ("sorted by age:",sort_df)
