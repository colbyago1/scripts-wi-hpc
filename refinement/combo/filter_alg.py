#!/usr/bin/env python3

import pandas as pd
import sys

input_filename = sys.argv[1]

# Extract the number by removing non-numeric characters
number = ''.join(filter(str.isdigit, sys.argv[1]))

output_filename = f'filtered_{number}.csv'

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(input_filename)

# Sort DataFrame based on the 'I_sc' field in ascending order
df['combo_score'] = 10 * df['rmsd'] + (100 - df['pLDDT']) * 0.75

# Sort the DataFrame by 'combo_score' in increasing order
df.sort_values(by='combo_score', inplace=True)

# Extract top n descriptions and save to a text file
n = 40-(10*int(number))
top_df = df.head(n)
top_df['description'].to_csv(output_filename, index=False, header=False)

print("Saved", output_filename)
