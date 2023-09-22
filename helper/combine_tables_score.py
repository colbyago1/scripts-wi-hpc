# !/usr/bin/env python3

import pandas as pd
import sys

# Read the CSV files into DataFrames

print(sys.argv[1])

df1 = pd.read_csv(sys.argv[1]) # score
df2 = pd.read_csv(sys.argv[2]) # other

#df2['pos'] = df2['pos'].astype(int)

df1.info()
df2.info()

# Apply the transformation to create the 'description' column
df2['description'] = df2[df2.columns[0]].apply(lambda x: x[:-4] + "_0001.pdb")

# Merge or concatenate the DataFrames based on the common column
combined_df = pd.merge(df1, df2, on='description')  # This performs an inner join

# print(df1['description'][0])
# print(df2['description'][0])



# Save the combined DataFrame to a new CSV file
combined_df.to_csv('combine_score_other.csv', index=False)

