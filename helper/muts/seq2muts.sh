#!/bin/bash

# Get reference sequence from fasta
reference=$(sed -n '2p' "$1")

# Process the first line separately to add the "rmsd" header
IFS='' read -r header < "$2"
new_header="$header,mutations"
echo "$new_header" > output_muts.csv 

# Loop through each line in the CSV file
tail -n +2 "$2" | while IFS=',' read -r seq rest_of_line; do
    # Run the Python script and capture its output
    muts=$(python /home/cagostino/work/scripts/helper/muts/findmuts.py $seq $reference 2>/dev/null)
    
    # Append the muts value to the line and create a new line
    new_line="$pdb_filename,$rest_of_line,$muts"

    # Write the new line to a temporary file
    echo "$new_line" >> output_muts.csv
done
