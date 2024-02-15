#!/bin/bash

# Create the CSV file and write header
# echo "description,pLDDT,pTM,ipTM" > output.csv
> CF_output.csv
while read -r line; do
    if grep -q "Query" <<< "$line"; then
        prefix=$(echo "$line" | awk '{print $5}')
    elif grep -q "rank_" <<< "$line"; then
        protein_name=$(echo "$line" | awk '{print $3}')
        pLDDT=$(echo "$line" | awk '{print $4}' | tr -cd '0-9.')
        echo "${PWD}/${prefix}_unrelaxed_${protein_name}.pdb,$pLDDT" >> CF_output.csv
    fi
done < log.txt
