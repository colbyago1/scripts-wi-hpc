#!/usr/bin/env python3

import pandas as pd
import sys

input_filename = sys.argv[1]
output_filename = 'filtered.csv'

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(input_filename)

# Get total score of reference structure
# ref_score =  

# Sort DataFrame based on the 'I_sc' field in ascending order
filtered = df[(df['total_score'] < -500) & (df['numDisulfs'] > 5)]

# Extract top 100 descriptions and save to a text file
top_descriptions = filtered['description']
top_descriptions.to_csv(output_filename, index=False, header=False)

print("Saved", output_filename)
