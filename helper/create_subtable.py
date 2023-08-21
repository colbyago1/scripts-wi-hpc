#!/usr/bin/env python3

import pandas as pd

input_filename = 'output_files/combined_score.csv'
output_filename = 'top_10.txt'

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(input_filename)

# Sort DataFrame based on the 'I_sc' field in ascending order
sorted_df = df.sort_values(by='I_sc', ascending=True)

# Extract top 100 descriptions and save to a text file
top_descriptions = sorted_df.head(10)['description']
top_descriptions.to_csv(output_filename, index=False, header=False)

print("Saved", output_filename)
