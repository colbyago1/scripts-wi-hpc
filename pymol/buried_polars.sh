#!/bin/sh
# Find buried polars

pdb="$1"

/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $pdb --writeNormSasa --reportByResidue | tail -n +14 | head -n -2 > SASA.txt

# init csv
echo "resi,sasa" > SASA.csv

# Loop through the file line by line
while IFS= read -r line; do
    # Extract the second and fifth words
    resi=$(echo "$line" | awk '{print $2}')
    sasa=$(echo "$line" | awk '{print $5}')
    # Print or store the second and fifth words as needed
    echo "$resi,$sasa" >> SASA.csv
done < SASA.txt

~/work/scripts/pymol/buried_polars.py $pdb SASA.csv

rm SASA.txt SASA.csv