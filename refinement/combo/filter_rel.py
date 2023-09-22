#!/usr/bin/env python3

import pandas as pd
import sys

input_filename = sys.argv[1]
wt_rmsd = float(sys.argv[2])
wt_plddt = float(sys.argv[3])

# Extract the number by removing non-numeric characters
number = int(''.join(filter(str.isdigit, sys.argv[1])))

output_filename = f'filtered_{number}.csv'

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(input_filename)

# find plddt and rmsd
rmsd = 0
plddt = 0
n=5
if number == 1:
    print("number = 1")
    rmsd = wt_rmsd
    plddt = wt_plddt
else:
    print("number > 1")
    # possibly include this to filter out muts that are worse than the wt (use a factor > 1 for rmsd and < 1 for plddt)
    # df = df[(df['pLDDT'] >= wt_plddt) & (df['rmsd'] <= wt_rmsd)]
    tmp_df = pd.read_csv(f'output_rmsd_{number-1}.csv')
    sorted_df = df.sort_values(by='rmsd')
    top_df = sorted_df.head(n)
    rmsd = top_df['rmsd'].mean()
    sorted_df = df.sort_values(by='pLDDT', ascending=False)
    top_df = sorted_df.head(n)
    plddt = top_df['pLDDT'].mean()

print(rmsd,plddt)

# possibly use this option that multiplies wt_plddt and rmsd by a factor
# rmsd = wt_rmsd / (number * 1.1)
# plddt = wt_plddt * (number * 1.1)

# selection
# satifies both creteria
# df=df[(df['rmsd']<=wt_plddt) & (df['pLDDT']>=wt_rmsd)]
# satifies either creteria
df=df[(df['rmsd']<=plddt) | (df['pLDDT']>=rmsd)]

# Extract top n descriptions and save to a text file
n = 40-(10*int(number))
# n = 10
top_df = df.head(n)
top_df['description'].to_csv(output_filename, index=False, header=False)

print("Saved", output_filename)
