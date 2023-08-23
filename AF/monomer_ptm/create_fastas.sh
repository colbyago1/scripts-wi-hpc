#!/bin/bash

file="filtered.csv"

# Iterate over each line in file1
while IFS= read -r line; do
    n=$((++count))
    
    output_file="seq$(printf "%043" $n).fa"

    # Create the output file with the desired content
    echo ">seq$(printf "%043" $n)" > "$output_file"
    echo "$line" >> "$output_file"
done < "$file"
