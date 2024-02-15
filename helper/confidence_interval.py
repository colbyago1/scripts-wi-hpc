#!/usr/bin/env python3

import sys
import pandas as pd
import numpy as np
from scipy import stats

if len(sys.argv) < 2:
    print("Usage: python confidence_interval.py <csv_file>")
    sys.exit(1)

csv_file = sys.argv[1]

# Read the CSV file into a DataFrame
try:
    df = pd.read_csv(csv_file)
except FileNotFoundError:
    print(f"Error: {csv_file} not found.")
    sys.exit(1)

# Extract data from the second column
second_column_data = df.iloc[:, 1].tolist()

# Calculate mean and standard deviation
mean = np.mean(second_column_data)
std_dev = np.std(second_column_data, ddof=0)  # ddof=0 for population standard deviation

# Calculate standard error of the mean
sem = std_dev / np.sqrt(len(second_column_data))

# Calculate 95% confidence interval using the Z-distribution
ci = stats.norm.interval(0.95, loc=mean, scale=sem)

print("95% Confidence Interval:", ci)

