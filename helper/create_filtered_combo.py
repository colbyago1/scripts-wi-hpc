#!/usr/bin/env python3

import pandas as pd
import sys

input_filename = sys.argv[1]
output_filename = 'combo2.csv'

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(input_filename)

# Sort DataFrame based on the 'I_sc' field in ascending order
df2 = df.copy()
df2['combo_score'] = 10 * df2['rmsd'] + (100 - df2['pLDDT']) * 0.75

# Sort the DataFrame by 'combo_score' in increasing order
df2.sort_values(by='combo_score', inplace=True)

df2 = df2['description'].head(100)

df2.to_csv(output_filename, index=False, header=False)

print("Saved", output_filename)
