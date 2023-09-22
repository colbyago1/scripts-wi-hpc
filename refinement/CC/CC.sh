#!/bin/sh

# input protein
pdb="$1"

# Run findDisulfs
/home/dwkulp/software/mslib.git/mslib/bin/findDisulfides --pdb $pdb --disulfPdb /home/dwkulp/wistar/data/disulfides/full_pdb_190722/CYS_CYS.bin --speak findDisulfides --binaryDB --modelBest --fasta

rm *bestDisulf*

source $HOME/.bashrc
bio
wt=$(python /home/cagostino/work/scripts/helper/pdb2seq.py $pdb)
length=${#wt}

##################################################################
######################### Epitope module #########################
##################################################################

# # * = mutatable
# substrings=("CY[A-Z]Y" "TQNGTSSAC" "WLTHLNY" "HHPGTDKDQIFL" "IPSRI")
# mutations=("CY**" "T*NGTSS**" "W*TH*NY" "H******D**FL" "I****")
# pdb_file="$HOME/work/workspace/H3RBS/rosettaLeads/relaxed/$pdb.pdb"

# # Initialize an empty array to store positions
# position_strings=()
# mutate_positions=()

# index=0
# # Loop through the substrings
# for substring in "${substrings[@]}"; do
#     # Find positions of the substring
#     positions=($(echo "$wt" | grep -bo "$substring" | cut -d':' -f1))

#     # Check the length of positions array
#     if [ "${#positions[@]}" -gt 1 ]; then
#         echo "Warning: Multiple positions found for substring '$substring'"

#     elif [ "${#positions[@]}" -lt 1 ]; then
#         echo "Warning: No positions found for substring '$substring'"
#     else
#         # Get the single position
#         position="${positions[0]}"

#         # Count the number of '[' characters in the substring
#         bracket_count=$(echo "$substring" | tr -cd '[' | wc -c)

#         # Calculate the ending position by subtracting 4 times the bracket count
#         end_position=$((position + ${#substring} - 4 * bracket_count))

#         for ((i = position + 1; i <= end_position; i++)); do
#             # find mutate positions and store in array
#             ((mutate_posi=$i-$position-1))
#             if [ "${mutations[index]:$mutate_posi:1}" != "*" ]; then
#                 mutate_positions+=("$i")
#             fi
#         done
#     fi
#     # Increment the counter
#     ((index++))
# done

# # mutate positions
# echo "mutate positions"
# echo "${mutate_positions[@]}"

##################################################################
##################################################################
##################################################################

# create fastas
for seq in $(awk 'NR % 2 == 0' DS_${pdb::-4}.fasta);
do
    muts=()
    for ((i=0; i<length; i++)); do
        if [[ -z "${mutate_positions[@]}" || ! " ${mutate_positions[@]} " =~ " $((i + 1)) " ]]; then
            char_wt="${wt:i:1}"
            char_seq="${seq:i:1}"
            # does not allow for disruption of current CC
            if [ "$char_wt" != "$char_seq" ]
            then
                muts+=("$char_seq$((i+1))")
            fi
        fi
    done
    # change this to -gt 0 for CC with existing C
    if [ "${#muts[@]}" -eq 2 ]
    then
        echo ">${pdb::-4}_${muts[0]}_${muts[1]}" > "${pdb::-4}_${muts[0]}_${muts[1]}.fa"
        echo "$seq" >> "${pdb::-4}_${muts[0]}_${muts[1]}.fa"
    fi
done

micromamba activate /home/dwkulp/software/miniconda3/envs/esmfold2
module load CUDA
export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm

# NNK
for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
        do
        	sleep 1
        done
	sbatch ~/work/scripts/refinement/CC/submit.sh "$f"
done