# !/usr/bin/env python3

import pandas as pd
import os
import shutil
import sys

#load the data into a pandas dataframe
fname = 'output.csv'
df = pd.read_csv(fname, names='Filename Unbound Ratio'.split(), index_col=False).dropna()

#filter
CUTOFF = float(sys.argv[1]) * float(sys.argv[2])
filtered_df = df.query(f'Unbound<{CUTOFF}')

# Get the top ten rows based on the "Ratio" column
top_design_df = filtered_df.nlargest(100, "Ratio")

if not os.path.exists("topdesigns"): os.makedirs("topdesigns")
for i in top_design_df['Filename'].tolist(): shutil.copy(i, 'topdesigns')
top_design_df.to_csv('topdesigns/output.csv', index=False)

for i in range(1,int(sys.argv[3])+1):
    if not os.path.exists(f"topdesigns/d{i}"): os.makedirs(f"topdesigns/d{i}")
    # Filter rows where a specific column contains '__'
    di_df = filtered_df[filtered_df['Filename'].str.count('__') == i]

    # Get the top ten rows based on the "Ratio" column
    top_design_df = di_df.nlargest(10*i, "Ratio")

    for j in top_design_df['Filename'].tolist(): shutil.copy(j, f"topdesigns/d{i}")
    top_design_df.to_csv(f"topdesigns/d{i}/output.csv", index=False)

