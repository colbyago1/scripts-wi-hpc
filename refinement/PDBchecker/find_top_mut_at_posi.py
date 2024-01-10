#!/usr/bin/env python3

import pandas as pd
import sys

posi = sys.argv[1]
filename = sys.argv[2]
not_allowed = sys.argv[3]

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(filename)

# Filter only rows containing posi
df = df[df.iloc[:, 0].str.contains(f"0001_{posi}[A-Z].pdb")]

# Sort the DataFrame by 'pLDDT' in decreasing order
df.sort_values(by='pLDDT', inplace=True, ascending=False)

# Print df.iloc[:, 0] for top row
index = 0
while df.iloc[index, 0][-5] in not_allowed:
    index+=1
print(df.iloc[index, 0][-5])