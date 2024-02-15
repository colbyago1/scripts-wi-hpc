#!/bin/bash

# Create the CSV file and write header
echo "description,pLDDT,pTM" > output.csv

# Loop through the files
for filename in slurm-*.out; do
    if [ -f "$filename" ]; then
        while read -r line; do
            if [[ "$line" =~ Predicted\ structure\ for\ ([^[:space:]]+)\ with\ length\ [[:digit:]]+,\ pLDDT\ ([[:digit:].]+),\ pTM\ ([[:digit:].]+)\ in ]]; then
                protein_name="${BASH_REMATCH[1]}.pdb"
                pLDDT="${BASH_REMATCH[2]}"
                pTM="${BASH_REMATCH[3]}"
                echo "$protein_name,$pLDDT,$pTM" >> output.csv
            fi
        done < "$filename"
    fi
done