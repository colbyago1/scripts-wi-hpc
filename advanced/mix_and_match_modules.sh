#!/bin/bash

# limitations:
# intra-topology (need to make saving of contigs dependent on contig names or absolute contig order)
# intra-topology (need to make starts and ends independent of substring order)

# defn:
# find best scoring modules (non-epitope) and mix and match (include a clash check)
# need to make a backbone PDB and run clash check

# run on top scoring designs (v1)

# P1: MIX
substrings=("ATRFASVYAWN" "LYNSASFSTFKC" "VIAWNSNNLDSKVGGNYNYLYRLFRKSNLKPFERDISTEIYQAGSTPCNGVEGFNCYFPLQSYGFQPTNGVGYQPYRVV" "DSFVIRGDEVRQIAPGQTGKIADYNYKLP")
> mnm.csv
> prplddt.csv
for pdb in *pdb; do
    echo $pdb

    # get sequence (chain A)
    seq=$(cat $pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
    echo $seq
    length=$(echo $seq | tr -d '\n' | wc -c)

    # calculate start and end positions of contigs in sequence
    starts=()
    ends=()
    for substring in "${substrings[@]}"; do
        # Find positions of the substring
        positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

        # Check the length of positions array
        if [ "${#positions[@]}" -gt 1 ]; then
            echo "Warning: Multiple positions found for substring '$substring'"
            echo "${positions[@]}"
            positions[0]=${positions[1]}
            echo "${positions[@]}"
        elif [ "${#positions[@]}" -lt 1 ]; then
            echo "Warning: No positions found for substring '$substring'"
        fi
            # Get the single position
            starts+=("${positions[0]}")
            # Calculate the ending position 
            ends+=("$((positions[0] + ${#substring}))")
    done
    echo ${starts[@]}
    echo ${ends[@]}

    # Find scaffold positions
    for ((i=0; i<${#starts[@]}; i++)); do
        if [ $i -eq 0 ]; then
            # Print numbers from 1 to starts[i]
            echo $pdb,$i,$(seq 1 $((starts[i] - 1))) >> mnm.csv
        else
            # Print numbers from ends[i-1] to starts[i]
            echo $pdb,$i,$(seq $((ends[i-1] + 1)) $((starts[i] - 1))) >> mnm.csv
        fi
    done
    # Print numbers from ends[last] to length
    echo $pdb,${#starts[@]},$(seq $((ends[${#starts[@]} - 1] + 1)) $length) >> mnm.csv

    # calculate prplddt
    for ((i=0; i<${#starts[@]} + 1; i++)); do
        positions=($(grep $pdb,$i mnm.csv | awk -F',' '{print $3}'))
        # echo ${positions[@]}
        # get prplddt
        prplddt=()
        for p in "${positions[@]}"; do
            # echo $p
            prplddt+=("$(awk -v posi="$p" '/^ATOM/ && $3 == "CA" && $6 == posi {print $11}' "$pdb")")
            # echo "$(awk -v posi="$p" '/^ATOM/ && $3 == "CA" && $6 == posi {print $11}' "$pdb")"
        done
        # echo ${prplddt[@]}
        sum=0
        for p in "${prplddt[@]}"; do
            sum=$(echo "$sum + $p" | bc)
        done
        # Calculate the mean
        count=${#prplddt[@]}
        scaffold_pLDDT=$(echo "scale=2; $sum / $count" | bc)
        echo $pdb,$i,$scaffold_pLDDT,${positions[@]} >> prplddt.csv
    done
done

# P2: MATCH
# sort csv by prplddt
sort -t',' -k3,3 -r -o prplddt.csv prplddt.csv
# split into ids
for ((i=0; i<${#substrings[@]} + 1; i++)); do
    awk -F',' -v id="$i" '$2 == id' prplddt.csv | head -n 1 > $i.csv
done

for ((i=0; i<${#substrings[@]} + 1; i++)); do
    awk -F',' -v id="$i" '$2 == id' prplddt.csv | head -n 1 > $i.csv
done

# Assemble PBDs

# iterate through all combinations (make permutation strings or something)

# add positions from each pdb into new pdb file (instead of aligning designs to epitope, I am using rfDiffusion backbones)
base="${pdb%%relaxed*}"
base=${base::-1}
base=$(basename "$base")
base="${base%%_seq*}"
backbone=$(dirname $(dirname $PWD))/${base}/${base}.pdb
for p in "${positions[@]}"; do
    # echo $p
    awk -v posi="$p" '$6 == posi {print $0}' "$backbone" >> mnm.pdb
done

# may have to do another positions thing to add the epitope of the first pdb (for backbone comparisons)

# # run clashCheck
# output=$(/home/dwkulp/software/mslib.git/mslib/bin/clashCheck --pdblist ${pdb::-4}_cc.pdb)
#     clashes=$(echo "$output" | awk '{print $NF}' | tail -n 1)
#     echo "Clashes: $clashes"
#     ### proteinMPNN ###
#     if [ $clashes -eq 0 ]; then
# # if passes add sequence to new fasta file
mnm_seq=$(cat mnm.pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
echo $mnm_seq >> mnm.fasta

# run on top scoring scaffolds (v2)
