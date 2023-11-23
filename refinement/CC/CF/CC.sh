#!/bin/sh
#SBATCH --job-name=CC
#SBATCH -c 1
#SBATCH --mem 128GB
#SBATCH --partition=defq
#SBATCH --time=0-24:00:00

# input protein
pdb="$1"

# Run findDisulfs
/home/dwkulp/software/mslib.git/mslib/bin/findDisulfides --pdb $pdb --disulfPdb /home/dwkulp/wistar/data/disulfides/full_pdb_190722/CYS_CYS.bin --speak findDisulfides --binaryDB --modelBest --fasta

rm *bestDisulf*

wt=$(cat $pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
length=${#wt}

# uncomment to prevent disulfides to epitope

##################################################################
######################### Epitope module #########################
##################################################################

# # * = mutatable
# substrings=("NLWVTVYYGVPVWK" "KIEPLGVAPTRCKRR" "LGFLGAAGSTMGAASMTLTVQARNLLS" "GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD")

# # Initialize an empty array to store positions
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

# create fastas (modified for trimers)
for seq in $(awk 'NR % 2 == 0' DS_${pdb::-4}.fasta);
do
    muts=()
    for ((i=0; i<length; i++)); do
        if [[ -z "${mutate_positions[@]}" || ! " ${mutate_positions[@]} " =~ " $((i + 1)) " ]]; then
            char_wt="${wt:i:1}"
            char_seq_1="${seq:i:1}"
            char_seq_2="${seq:(( length + i )):1}"
            char_seq_3="${seq:(( 2 * length + i )):1}"
            # does not allow for disruption of current CC
            if [ "$char_wt" != "$char_seq_1" ]; then
                muts+=("$char_seq_1$((i+1))")
            fi
            if [ "$char_wt" != "$char_seq_2" ]; then
                muts+=("$char_seq_2$((i+1))")
            fi
            if [ "$char_wt" != "$char_seq_3" ]; then
                muts+=("$char_seq_3$((i+1))")
            fi
        fi
    done
    # change this to -gt 0 for CC with existing C
    if [ "${#muts[@]}" -eq 2 ]
    then
        # echo ">${pdb::-4}_${muts[0]}_${muts[1]}" > "${pdb::-4}_${muts[0]}_${muts[1]}.fa"
        # echo $(echo $wt | sed "s/./C/${muts[0]:1}" | sed "s/./C/${muts[1]:1}") >> "${pdb::-4}_${muts[0]}_${muts[1]}.fa"
        mut_seq=$(echo $wt | sed "s/./C/${muts[0]:1}" | sed "s/./C/${muts[1]:1}")
        sed -e '3s/.*/'"$mut_seq"'/' -e '5s/.*/'"$mut_seq"'/' "${pdb::-4}.a3m" > "${pdb::-4}_${muts[0]}_${muts[1]}.a3m"
    fi
done