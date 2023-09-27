#!/bin/bash

# Create an array of files in the current directory
files=(*)

for ((i = 0; i < ${#files[@]}; i++)); do
    # Inner loop to iterate through subsequent files
    for ((j = i + 1; j < ${#files[@]}; j++)); do
        # Get the second line of the current file in the outer loop
        seqi=$(sed -n '2p' "${files[i]}")
        # Get the second line of the current file in the inner loop
        seqj=$(sed -n '2p' "${files[j]}")
        # Compare the second lines
        if [ "$seqi" = "$seqj" ]; then
            echo "Dup found between ${files[i]} and ${files[j]}"
        fi
    done
done
