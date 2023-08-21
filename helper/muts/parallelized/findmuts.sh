#!/bin/bash

reference="$1"

# Loop through each line in the CSV file
while IFS=',' read -r pdb_filename rest_of_line; do
    echo "Processing: $pdb_filename"
    if [ -e "$pdb_filename" ]; then
        echo "File exists: $pdb_filename"
        # Run the Python script and capture its output
        muts=$(python /home/cagostino/work/scripts/helper/muts/parallelized/findmuts.py $pdb_filename $reference 2>/dev/null)
        echo "$muts"
        # Append the muts value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$muts"
    else
        # If 'p' doesn't match, keep the line unchanged
        new_line="$pdb_filename,$rest_of_line"
    fi
    # Write the new line to a temporary file
    echo "$new_line" >> "$2.output.csv"
done < "$2"

