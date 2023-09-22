# !/usr/bin/env python3

import pandas as pd
import sys

#load the data into a pandas dataframe
df = pd.read_csv(sys.argv[1], names='Filename Unbound Ratio'.split(), index_col=False)

#filter
CUTOFF = float(sys.argv[2]) * float(sys.argv[4])
filtered_df = df.query(f'Unbound<{CUTOFF}')

# Get the top n rows based on the "Ratio" column
sorted_df = filtered_df.sort_values(by="Ratio", ascending=False)
top_designs = sorted_df.head(int(sys.argv[3]))

for td in top_designs['Filename']: print(td)