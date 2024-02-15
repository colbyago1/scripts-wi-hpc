#!/bin/bash

### WARNING: ONLY WORKS FOR CHAIN A!!! ###

# ID = chain + resi
    # csvs = useful to compare positions of interest across designs (individually)
    # combined csv = useful to compare positions of interest across designs (all at once)
    # IDs = (A1 A2 A3) corresponds to positions 1,2,3 in chain A
# ID = position in epitope
    # csvs = same as above but positions are relative to epitope
    # combined csv = same as above but positions are relative to epitope
    # IDs = (A1 A2 A3) corresponds to first second and third position in epitope (from substrings list) in chain A
# ID = contig
    # csvs = useful to compare positions of interest across designs (all at once)
    # combined csv = not useful
    # IDs = (A1 A2 A3) corresponds to contigs 1,2,3 (from substrings list) in chain A

# Run get_perPresidue_pLDDT.sh on all PDBs in a directory
echo "file,chain,resi,resn,pLDDT,ID" > combined_prpLDDT.csv
for p in *pdb; do
    ~/work/scripts/advanced/get_perResidue_pLDDT.sh $p
    tail -n +2 prpLDDT.csv >> combined_prpLDDT.csv
done
rm prpLDDT.csv

# Filter rows based on ID
IDs=(A1 A2 A3)
for ID in "${IDs[@]}"; do
    echo "file,chain,resi,resn,pLDDT,ID" > "${ID}.csv"
    awk -F ',' -v id="$ID" '$6 == id' combined_prpLDDT.csv >> "${ID}.csv"
done

# Find mean of IDs
string=""
for f in A*.csv; do
    string+=",${f::-4}"
    > ${f::-4}_mean.csv
    tail -n +2 $f | awk -F',' '{sum[$1]+=$5; count[$1]++} END {for (key in sum) print key "," sum[key]/count[key]}' >> ${f::-4}_mean.csv
done

# Find mean across IDs
echo file$string,mean > mean.csv
for p in *pdb; do
    line=$(grep "$p" *_mean.csv | awk -F',' '{print $2}' | paste -sd ",")
    mean=$(echo $line | tr ',' '\n' | awk '{sum += $1} END {print sum/NR}')
    echo ${p},$line,$mean >> mean.csv
done