#!/bin/bash

# Create the CSV file and write header
echo "description,pLDDT,pTM,ipTM,rmsd" > output.csv

for d in pMPNN_0.[12]/pmpnn_seqs/seqs/output/; do
    cd $d
    >output.csv
    if [ -f "log.txt" ]; then
        prefix=
        while read -r line; do
            if grep -q "Query" <<< "$line"; then
                prefix=$(echo $line | awk '{print $5}')
            elif grep -q "rank_" <<< "$line"; then
                protein_name=$(echo "$line" | awk '{print $3}')
                pLDDT=$(echo "$line" | awk '{print $4}' | tr -cd '0-9.')
                pTM=$(echo "$line" | awk '{print $5}' | tr -cd '0-9.')
                ipTM=$(echo "$line" | awk '{print $6}' | tr -cd '0-9.')
                rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 ${prefix}_unrelaxed_${protein_name}.pdb --pdb2 /home/cagostino/work/workspace/prefusion_gp41/CCCP/allbb_rechain.pdb --sele1 name CA --sele2 name CA --noOutputPdb | awk '/RMSD/{print $2}')
                echo "${prefix}_unrelaxed_${protein_name}.pdb,$pLDDT,$pTM,$ipTM,$rmsd" >> output.csv
            fi
        done < "log.txt"
    fi
    cd -
done

cat pMPNN_0.[12]/pmpnn_seqs/seqs/output/output.csv >> output.csv