import pandas as pd

input_filename = "AF.csv"
output_filename = "filtered.csv"

# Read the CSV file into a Pandas DataFrame
df = pd.read_csv(input_filename)

# Drop duplicates based on the second column and keep all columns
# unique_df = df.drop_duplicates(subset=df.columns[1])

# Sort the DataFrame based on the second column
sorted_df = df.sort_values(by=df.columns[1], ascending=False)
# sorted_df.to_csv(output_filename, index=False, header=False)
# Calculate the number of rows in the bottom 50%
bottom_half_rows = len(sorted_df) // 2

# Keep only the bottom 50% of rows
bottom_half_df = sorted_df.iloc[:bottom_half_rows]

# Save the second column to a text file
column_to_save = bottom_half_df.iloc[:, 0]
column_to_save.to_csv(output_filename, index=False, header=False)

