#!/bin/bash

# BG18
csv_path="/home/cagostino/work/workspace/AbsBinders/sgang/AF/27Oct23_BG18mat_Set2.csv"
path_to_backbone="/home/cagostino/work/workspace/AbsBinders/sgang/rfDiffusion_binding/BG18"

# Create the CSV file and write header
echo "description,pLDDT,pTM,ipTM,rmsd" > output.csv

for f in */log.txt; do
    dir=$(dirname $f)
    while read -r line; do
        if grep -q "Query" <<< "$line"; then
            prefix=$(echo $line | awk '{print $5}')
        elif grep -q "rank_" <<< "$line"; then
            protein_name=$(echo "$line" | awk '{print $3}')
            pLDDT=$(echo "$line" | awk '{print $4}' | tr -cd '0-9.')
            pTM=$(echo "$line" | awk '{print $5}' | tr -cd '0-9.')
            ipTM=$(echo "$line" | awk '{print $6}' | tr -cd '0-9.')
            backbone=$(grep $dir $csv_path | awk -F',' '{print $2}')
            /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path_to_backbone/$backbone --pdb2 $dir/${prefix}_unrelaxed_${protein_name}.pdb --sele1 name CA and chain H --sele2 name CA and chain B+A
            rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path_to_backbone/$backbone --pdb2 $dir/${prefix}_unrelaxed_${protein_name}.pdb --sele1 name CA and chain A --sele2 name CA and chain C --noOutputPdb --noAlign | awk '/RMSD/{print $2}')
            echo "$dir/${prefix}_unrelaxed_${protein_name}.pdb,$pLDDT,$pTM,$ipTM,$rmsd" >> output.csv
            rm ${prefix}_unrelaxed_${protein_name}-aligned.pdb
        fi
    done < $f
done

# # PGT121
# csv_path="/home/cagostino/work/workspace/AbsBinders/sgang/AF/06Oct23_PGT121mat_top50.csv"
# path_to_backbone="/home/cagostino/work/workspace/AbsBinders/sgang/rfDiffusion_binding/PGT121"

# # Create the CSV file and write header
# echo "description,pLDDT,pTM,ipTM,rmsd" > output.csv

# for f in */log.txt; do
#     dir=$(dirname $f)
#     while read -r line; do
#         if grep -q "Query" <<< "$line"; then
#             prefix=$(echo $line | awk '{print $5}')
#         elif grep -q "rank_" <<< "$line"; then
#             protein_name=$(echo "$line" | awk '{print $3}')
#             pLDDT=$(echo "$line" | awk '{print $4}' | tr -cd '0-9.')
#             pTM=$(echo "$line" | awk '{print $5}' | tr -cd '0-9.')
#             ipTM=$(echo "$line" | awk '{print $6}' | tr -cd '0-9.')
#             backbone=$(grep $dir $csv_path | awk -F',' '{print $2}')
#             /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path_to_backbone/$backbone --pdb2 $dir/${prefix}_unrelaxed_${protein_name}.pdb --sele1 name CA and chain H --sele2 name CA and chain B+A --regex ".*(QVQIDISVAPGETARISCGEKSLGSRAVQWYQHRAGQAPSLIIYNNQDRPSGIPERFSGSPDSPFGTTATLTITSVEAGDEADYYCHIWDSRVPTKWVFGGGTTLTVL).*" --regex ".*(QMQLQESGPGLVKPSETLSLTCSVSGASISDSYWSWIRRSPGKGLEWIGYVHKSGDTNYSPSLKSRVNLSLDTSKNQVSLSLVAATAADSGKYYCARTLHGRRIYGIVAFNEWFTYFYMDVWGNGTQVTVSSA).*"
#             rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path_to_backbone/$backbone --pdb2 $dir/${prefix}_unrelaxed_${protein_name}.pdb --sele1 name CA and chain A --sele2 name CA and chain C --noOutputPdb --noAlign | awk '/RMSD/{print $2}')
#             echo "$dir/${prefix}_unrelaxed_${protein_name}.pdb,$pLDDT,$pTM,$ipTM,$rmsd" >> output.csv
#             rm ${prefix}_unrelaxed_${protein_name}-aligned.pdb
#         fi
#     done < $f
# done

# # CH01
# csv_path="/home/cagostino/work/workspace/AbsBinders/msangster/AF/40_order_candidates_and_pdb_locations.csv"
# path_to_backbone="/home/cagostino/work/workspace/AbsBinders/msangster/rfDiffusion_binding/CH01"

# # Create the CSV file and write header
# echo "description,pLDDT,pTM,ipTM,rmsd" > output.csv

# for f in */log.txt; do
#     dir=$(dirname $f)
#     while read -r line; do
#         if grep -q "Query" <<< "$line"; then
#             prefix=$(echo $line | awk '{print $5}')
#         elif grep -q "rank_" <<< "$line"; then
#             protein_name=$(echo "$line" | awk '{print $3}')
#             pLDDT=$(echo "$line" | awk '{print $4}' | tr -cd '0-9.')
#             pTM=$(echo "$line" | awk '{print $5}' | tr -cd '0-9.')
#             ipTM=$(echo "$line" | awk '{print $6}' | tr -cd '0-9.')
#             backbone=$(grep $dir $csv_path | awk -F',' '{print $2}' | tr -d '\r')
#             seq=$(cat $dir/${prefix}_unrelaxed_${protein_name}.pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "C" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
#             end=${#seq}
#             start=$((end - 7))
#             /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path_to_backbone/$backbone --pdb2 $dir/${prefix}_unrelaxed_${protein_name}.pdb --sele1 name CA and chain M+N --sele2 name CA and chain A+B
#             rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path_to_backbone/$backbone --pdb2 ${prefix}_unrelaxed_${protein_name}-aligned.pdb --sele1 name CA and chain A --sele2 name CA and chain C and not \(chain C and resi $start-$end\) --noOutputPdb --noAlign | awk '/RMSD/{print $2}')
#             echo "$dir/${prefix}_unrelaxed_${protein_name}.pdb,$pLDDT,$pTM,$ipTM,$rmsd" >> output.csv
#             rm ${prefix}_unrelaxed_${protein_name}-aligned.pdb
#         fi
#     done < $f
# done