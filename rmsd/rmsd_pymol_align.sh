#!/bin/bash

reference="$1"

# Process the first line separately to add the "rmsd" header
IFS='' read -r header < "$2"
new_header="$header,rmsd"
echo "$new_header" > output_rmsd.csv

# Loop through each line in the CSV file
tail -n +2 "$2" | while IFS=',' read -r pdb_filename rest_of_line; do
    if [ -e "$pdb_filename" ]
    then
        # Run the Python script and capture its output
        output=$(python /home/cagostino/work/scripts/rmsd/rmsd_pymol_align.py $pdb_filename $reference)

        # Extract the last word from the output using awk
        rmsd=$(echo "$output" | awk '{print $NF}')
        
        # Append the RMSD value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$rmsd"
    elif [ -e "${pdb_filename::-9}${pdb_filename:(-4)}" ]
    then
        # Run the Python script and capture its output
        output=$(python /home/cagostino/work/scripts/rmsd/rmsd_pymol_align.py "${pdb_filename::-9}${pdb_filename:(-4)}" $reference)

        # Extract the last word from the output using awk
        rmsd=$(echo "$output" | awk '{print $NF}')
        
        # Append the RMSD value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$rmsd"
    else
        # If 'p' doesn't match, keep the line unchanged
        new_line="$pdb_filename,$rest_of_line"
    fi
    # Write the new line to a temporary file
    new_line="${new_line//,,/,}"
    echo "$new_line" >> output_rmsd.csv
done

