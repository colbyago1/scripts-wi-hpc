#!/bin/bash

mkdir output_files

# Create the CSV file and write header
echo "description,pLDDT,pTM" > output_files/output.csv

for d in */; do
    cd $d
    if [ -f "log.txt" ]; then
        prefix=
        while read -r line; do
            if grep -q "Query" <<< "$line"; then
                prefix=$(echo $line | awk '{print $5}')
            elif grep -q "rank_" <<< "$line"; then
                protein_name=$(echo "$line" | awk '{print $3}')
                pLDDT=$(echo "$line" | awk '{print $4}' | tr -cd '0-9.')
                pTM=$(echo "$line" | awk '{print $5}' | tr -cd '0-9.')
                echo "${prefix}_unrelaxed_${protein_name}.pdb,$pLDDT,$pTM" >> ../output_files/output.csv
                cp ${prefix}_unrelaxed_${protein_name}.pdb ../output_files/
            fi
        done < "log.txt"
    fi
    cd ..
done