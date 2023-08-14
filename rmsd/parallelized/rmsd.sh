#!/bin/bash

reference="$1"

# Loop through each line in the CSV file
while IFS=',' read -r pdb_filename rest_of_line; do
    if [ -e "$pdb_filename" ]
    then
        # Run the Python script and capture its output
        output=$(python /home/cagostino/work/scripts/rmsd/rmsd.py $pdb_filename $reference)

        # Extract the last word from the output using awk
        rmsd=$(echo "$output" | awk '{print $NF}')
        
        # Append the RMSD value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$rmsd"
    else
        # If 'p' doesn't match, keep the line unchanged
        new_line="$pdb_filename,$rest_of_line"
    fi
    # Write the new line to a temporary file
    echo "$new_line" >> "$2.output.csv"
done < "$2"
