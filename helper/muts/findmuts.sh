#!/bin/bash

reference="$1"

# Process the first line separately to add the "rmsd" header
IFS='' read -r header < "$2"
new_header="$header,mutations"
echo "$new_header" > output_muts.csv 

# Loop through each line in the CSV file
tail -n +2 "$2" | while IFS=',' read -r pdb_filename rest_of_line; do
    echo "Processing: $pdb_filename"
    if [ -e "$pdb_filename" ]; then
        echo "File exists: $pdb_filename"
        # Run the Python script and capture its output
        muts=$(python /home/cagostino/work/scripts/helper/muts/findmuts.py $pdb_filename $reference 2>/dev/null)
        echo "$muts"
        # Append the muts value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$muts"
    else
        # If 'p' doesn't match, keep the line unchanged
        new_line="$pdb_filename,$rest_of_line"
    fi
    # Write the new line to a temporary file
    echo "$new_line" >> output_muts.csv
done
