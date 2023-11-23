#!/bin/bash

#SBATCH --job-name=pMPNN
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --mem=12Gb
#SBATCH --time=200:00:00

substrings=("QEI" "VQ" "AVGIGAVFLGF" "RN" "NSS" "NYTQIIYGLLE")
ref="/home/cagostino/work/workspace/gp120-gp41_interface/PGT151/6MAR/rfDiffusion/A/6MAR_contigs_A.pdb"

# proteinMPNN
output_dir="./pmpnn_seqs"
if [ ! -d $output_dir ]
then
    mkdir -p $output_dir
fi

path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"
path_for_assigned_chains=$output_dir"/assigned_pdbs.jsonl"
path_for_fixed_positions=$output_dir"/fixed_pdbs.jsonl"
chains_to_design="A"

# save glycans to file
cat $ref | awk '$5 == "G"' > glycans
cat $ref | awk '$5 == "B"' > Ab

for pdb in *pdb; do
    echo $pdb

    ### align based on substrings ###
    
    # # get sequence from rfDiffusion outfile
    # seq=$(grep -A 3 ${pdb::-4} *out | tail -n 1 | awk '{print $NF}')

    # get sequence
    seq=$(cat $pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
    # echo $seq

    # get position of contigs and save to csv
    fixed_positions=()
    index=0
    # Loop through the substrings
    for substring in "${substrings[@]}"; do
        # Find positions of the substring
        positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

        echo "PSOI ${positions[@]}"
        # Check the length of positions array
        if [ "${#positions[@]}" -gt 1 ]; then
            echo "Warning: Multiple positions found for substring '$substring'"
            
            # Get the position before 
            position=$((positions[1] - 1))

            # Get the position after
            end_position=$((position + ${#substring} + 1))

            if [ "${seq:$position:1}" == "G" ] && [ "${seq:$end_position:1}" == "G" ]; then
                positions[0]=${positions[1]}
            fi

        elif [ "${#positions[@]}" -lt 1 ]; then
            echo "Warning: No positions found for substring '$substring'"
        else
            # Get the single position
            position="${positions[0]}"

            # Calculate the ending position by subtracting 4 times the bracket count
            end_position=$((position + ${#substring}))

            # Initialize an empty array to store positions
            position_list=()
            # Create an array of positions from start to end
            for ((i = position + 1; i <= end_position; i++)); do
                position_list+=("$i")
                # Echo the letter at that position
                # letter=$(echo "$seq" | cut -c "$i")
                # echo "Position $i: $letter"
            done
            fixed_positions+=("${position_list[*]}")
        fi
        # Increment the counter
        ((index++))
    done

    # echo "Fixed: ${fixed_positions[@]}"

    echo "$pdb,${fixed_positions[@]}" >> align.csv

    # align to template
    command="/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $ref --pdb2 $pdb --sele1 name CA and chain A --sele2 name CA and chain A"; for substring in "${substrings[@]}"; do command+=" --regex \".*($substring).*\""; done; eval "$command";

    ### add glycans to file ###
    grep '^ATOM\s\+[0-9]\+\s\+.*\s\+A\s\+[0-9]\+\s\+' "${pdb::-4}-aligned.pdb" > "${pdb::-4}_cc.pdb"
    cat <(echo "TER") Ab <(echo "TER") glycans <(echo "TER") <(echo "END")  >> "${pdb::-4}_cc.pdb"

    ### run clashCheck ###
    output=$(/home/dwkulp/software/mslib.git/mslib/bin/clashCheck --pdblist ${pdb::-4}_cc.pdb)
    clashes=$(echo "$output" | awk '{print $NF}' | tail -n 1)
    echo "Clashes: $clashes"

    ### proteinMPNN ###
    if [ $clashes -eq 0 ]; then
        echo "Running pMPNN"

        folder_with_pdbs="${pdb::-4}"
        mkdir -p "$folder_with_pdbs"
        mv "${pdb::-4}_cc.pdb" "$folder_with_pdbs/$pdb"

        python /home/cagostino/work/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

        python /home/cagostino/work/software/ProteinMPNN/helper_scripts/assign_fixed_chains.py --input_path=$path_for_parsed_chains --output_path=$path_for_assigned_chains --chain_list "$chains_to_design"

        python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_fixed_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_fixed_positions --chain_list "$chains_to_design" --position_list "${fixed_positions[*]}"

        python /home/cagostino/work/software/ProteinMPNN/protein_mpnn_run.py \
                --jsonl_path $path_for_parsed_chains \
                --chain_id_jsonl $path_for_assigned_chains \
                --fixed_positions_jsonl $path_for_fixed_positions \
                --out_folder $output_dir \
                --num_seq_per_target 10 \
                --sampling_temp "0.1" \
                --seed 37 \
                --batch_size 1 
    else
        echo "Skipping pMPNN"
    fi
    rm "${pdb::-4}_cc.pdb" "${pdb::-4}-aligned.pdb"
    echo
done

rm glycans Ab

# fix fasta files
for fasta in pmpnn_seqs/seqs/*.fa; do
    tail -n +3 "$fasta" | awk -v input_file="$(basename ${fasta::-3})" '{if (NR % 2 == 1) {$0=sprintf(">%s_seq%02d", input_file, ++i)} print}' > "${fasta::-3}.fasta"
done