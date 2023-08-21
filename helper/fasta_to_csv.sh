#!/bin/bash

input_file="$1"
output_file="${input_file::-3}.csv"  # Remove last three characters
prev_line=""

while IFS= read -r line; do
    if [ -n "$prev_line" ]; then
        combined_line="$prev_line,$line"
        echo "$combined_line" >> "$output_file"
        prev_line=""
    else
        prev_line=$(echo "$line" | grep -oP "global_score=\K\d+\.\d+")
    fi
done < "$input_file"
