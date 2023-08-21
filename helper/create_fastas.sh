#!/bin/bash

file1="filtered.csv"
file2="VH1-46_HC_translation.fasta"

# Iterate over each line in file1
while IFS= read -r line; do
    n=$((++count))
    
    output_file="seq$(printf "%04d" $n).fa"

    # Create the output file with the desired content
    echo ">seq$(printf "%04d" $n)" > "$output_file"
    echo "$line" >> "$output_file"
    cat "$file2" >> "$output_file"
done < "$file1"
