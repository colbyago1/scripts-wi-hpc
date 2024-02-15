#!/bin/bash

# fix slurm one for rfDiffusion, one for proteinMPNN
# name=
# rfDiffusion_job_ids= slurm-6856631.out
# proteinMPNN_job_ids= slurm-6865941.out

### counts ###

# test
# ls *canonical_mini*/dir*/run[0-9]05/pmpnn_seqs/seqs/*_21-*-monomer.fa

# number of backbones
bb=$(ls *canonical_mini*/dir*/run*/*[0-9].pdb | wc -l)
echo "rfDiffusion backbones: $bb"
# 57322

# number of sequences
seqs=$(ls *canonical_mini*/dir*/run*/pmpnn_seqs/seqs/V*-monomer.fa | wc -l)
echo "ProteinMPNN sequences: $seqs"
# 110

# number of pdbs passings case and clash (should equal sequences)
passing_pdbs=$(ls *canonical_mini*/dir*/run*/V*/V*pdb | wc -l)
echo "rfDiffusion backbones not case 5 and no clashes: $passing_pdbs"
# 5325

# number of "sym" with clashes
non_sym_clash=$(ls *canonical_mini*/dir*/run*/V*aln.pdb | wc -l)
echo "\"Symmetric\" motif scaffolding rfDiffusion backbones with clashes > 0: $non_sym_clash"
# 247
# number of sym with clashes
sym_clash=$(ls *canonical_mini*/dir*/run*/V*fix.pdb | wc -l)
echo "Symmetric motif scaffolding rfDiffusion backbones with clashes > 0: $sym_clash"
# 2165

# number of clashes
clash=$(ls *canonical_mini*/dir*/run*/V*{aln,fix}.pdb | wc -l)
echo "rfDiffusion backbones with clashes > 0: $clash"
# 2328

# broken
# # number trimers made
# trimers=$(ls *canonical_mini*/dir*/run*/*{aln,fix}* | wc -l)
# echo "rfDiffusion backbones not case 5: $trimers"
# # 17555

### arithmetic ###

# number of failures = number of backbones - number of sequences
# number of case failures = number of backbones - number trimers made

### QC ###

# get failure statements from rfDiffusion
echo "rfDiffusion_exits:" > rfDiffusion_exits.txt
tail -n 1 *canonical_mini*/dir*/run*/slurm-685* >> rfDiffusion_exits.txt

# cases
echo "cases:"
grep -hi "case" *canonical_mini*/dir*/run*/slurm-686* | sort | uniq -c

# clashes
echo "clashes=0:"
grep -i "clashes" *canonical_mini*/dir*/run*/slurm-686* | awk '$2==0 {print}' | wc -l
echo "clashes>0:"
grep -i "clashes" *canonical_mini*/dir*/run*/slurm-686* | awk '$2!=0 {print}' | wc -l

## TODO ###

# count linker length (backbone)?
grep "Timestep 2, input to next step" *canonical_mini*/dir*/run*/slurm-685* | awk '{print $NF}' > linkers_backbone.txt

# count linker length (sequence)?
awk 'FNR == 2 {print $0}' *canonical_mini*/dir*/run*/pmpnn_seqs/seqs/*-monomer.fa > linkers_sequence.txt

substrings=("NLWVTVYYGVPVWK" "KIEPLGVAPTRCKRR" "LGFLGAAGSTMGAASMTLTVQARNLLS" "GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD")

> linkers_sequence_hyphen.txt
while IFS= read -r seq; do
    
    # Initialize an empty array to store positions
    position_list=()

    for substring in "${substrings[@]}"; do
        # Find positions of the substring
        positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

        # Check the length of positions array
        if [ "${#positions[@]}" -gt 1 ]; then
            echo "Warning: Multiple positions found for substring '$substring'"

        elif [ "${#positions[@]}" -lt 1 ]; then
            echo "Warning: No positions found for substring '$substring'"
        else
            # Get the single position
            position="${positions[0]}"

            # Count the number of '[' characters in the substring
            bracket_count=$(echo "$substring" | tr -cd '[' | wc -c)

            # Calculate the ending position by subtracting 4 times the bracket count
            end_position=$((position + ${#substring} - 4 * bracket_count))

            # Create an array of positions from start to end
            for ((i = position; i < end_position; i++)); do
                position_list+=("$i")
            done
        fi
    done

    # Store the length of the sequence in a variable
    seq_length=${#seq}

    for ((i=0; i<seq_length; i++)); do
        # Check if the position is not in the position_list
        if ! [[ " ${position_list[@]} " =~ " $i " ]]; then
            # Replace the character at position i with '-'
            seq="${seq:0:i}-${seq:i+1}"
        fi
    done
    echo "$seq" >> linkers_sequence_hyphen.txt

done < "linkers_sequence.txt"

echo "linkers_backbone_lengths:" > linkers_backbone_lengths.txt
while IFS= read -r seq; do
    # Use awk to find consecutive hyphen regions and print their lengths
    echo $seq | awk -v RS="-+" 'NR>1 {printf "%d ", length(prev)} {prev=RT} END{printf "\n"}' >> linkers_backbone_lengths.txt
done < "linkers_backbone.txt"

echo "linkers_sequence_lengths:" > linkers_sequence_lengths.txt
while IFS= read -r seq; do
    # Use awk to find consecutive hyphen regions and print their lengths
    echo $seq | awk -v RS="-+" 'NR>1 {printf "%d ", length(prev)} {prev=RT} END{printf "\n"}' >> linkers_sequence_lengths.txt
done < "linkers_sequence_hyphen.txt"