# !/usr/bin/env python3

import pandas as pd
import sys

# Read the CSV files into DataFrames
df1 = pd.read_csv(sys.argv[1]) # AF
df2 = pd.read_csv(sys.argv[2]) # pMPNN

# Drop duplicates based on the second column and keep all columns
unique_df2 = df2.drop_duplicates(subset=df2.columns[1])

# Sort the DataFrame based on the first column
sorted_df2 = unique_df2.sort_values(by=unique_df2.columns[0])
sorted_df1 = df1.sort_values(by=df1.columns[0])

# Calculate the number of rows
df1_rows = int(len(df1) / 5)

# Keep only ...
filtered_df2 = sorted_df2.iloc[:df1_rows]

filtered_df2.info()

# Duplicate values based on your pattern
repeated_df2 = filtered_df2.reindex(filtered_df2.index.repeat(5)).reset_index(drop=True)

repeated_df2.info()

sorted_df1['pMPNN score'] = repeated_df2[repeated_df2.columns[0]]

sorted_df1.to_csv('combine_pMPNN_AF.csv', index=False)
