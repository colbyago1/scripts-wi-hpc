#!/bin/bash

#WARNING: change NNKpath

### SECTION I: FIND UNPAIRED CYSTEINES ###

# # Array to store job IDs
# job_ids=()

# # run disulfs
# for p in *pdb
# do
#     while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
#     do
#         sleep 1
#         rm *bestDisulf* 2>/dev/null
#     done
#     job_id=$(sbatch /home/cagostino/work/scripts/PDBchecker/run_disulfide.sh $p | awk '{print $4}')
#     job_ids+=("$job_id")
# done

# # wait
# for job_id in "${job_ids[@]}"
# do
#     while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
#     do
#         sleep 1
#     done
#     rm "slurm-$job_id.out"
# done

# rm *bestDisulf* 2>/dev/null

# # write fastas
# for p in *pdb
# do
#     python $HOME/work/scripts/helper/pdb2fa.py $p
# done

# mkdir fas
# mv *.fasta fas
# mkdir updated_fas

# > SECTION_I.log

# # check for disulfs
# for p in *pdb
# do
#     NNKpath=$(echo "$p" | sed 's/\(.*0001\).*/\1/')
#     NNKfile="$HOME/work/workspace/H3RBS/esm/$NNKpath/output.csv"

#     seq=$(sed -n '2p' "fas/${p::-4}.fasta")
#     length=${#seq}
#     cysteines=()
#     disulfs_info=()
#     mutations=()
#     non_mutations=()

#     echo "$p" >> SECTION_I.log

#     # Find cysteines
#     for ((i = 0; i < length; i++)); do
#         # Check if the current character is "C"
#         if [ "${seq:i:1}" = "C" ]; then
#             cysteines+=($((i + 1)))
#         fi
#     done

#     # Iterate through the cysteines
#     for ((i = 0; i < ${#cysteines[@]}; i++)); do
#         C1="${cysteines[i]}"
#         echo "$C1" >> SECTION_I.log
#         # Iterate through cysteines that come after the C1
#         for ((j = i + 1; j < ${#cysteines[@]}; j++)); do
#             C2="${cysteines[j]}"
#             #check if disulf exists (see example)
#             line=$(grep "A,$C1,CYS.*A,$C2,CYS" "${p::-4}.log")
#             if [ -n "$line" ]; then
#                 numDisulfs=$(echo "$line" | awk '{print $6}')
#                 echo "found CC between $C1 and $C2 with $numDisulfs disulfs" >> SECTION_I.log
#                 disulfs_info+=("$numDisulfs $C1 $C2")
#             fi
#         done
#     done

#     # Sort the array
#     disulfs_info=($(printf "%s\n" "${disulfs_info[@]}" | sort -nr))

#     # Iterate through disulfs_info
#     for ((i = 0; i < ${#disulfs_info[@]} / 3; i++)); do
#         # Check if both the second and third values are not in non_mutations
#         if [[ ! " ${non_mutations[*]} " =~ " ${disulfs_info[i * 3 + 1]} " ]] && [[ ! " ${non_mutations[*]} " =~ " ${disulfs_info[i * 3 + 2]} " ]]; then
#             non_mutations+=("${disulfs_info[i * 3 + 1]}" "${disulfs_info[i * 3 + 2]}")
#         fi
#     done

#     echo "non_mutations: ${non_mutations[@]}" >> SECTION_I.log

#     # Iterate through cysteines
#     for C in "${cysteines[@]}"; do
#         # Check if the element is not in non_mutations
#         if [[ ! " ${non_mutations[*]} " =~ " $C " ]]; then
#             mutations+=("$C")
#         fi
#     done

#     echo "mutations: ${mutations[@]}" >> SECTION_I.log
    
#     # mutate
#     for ((i=0; i<${#mutations[@]}; i++))
#     do
#         posi=${mutations[i]}

#         # Extract the character at the specified position
#         aa_at_posi="${seq:posi-1:1}"

#         # Get top scoring amino acid from NNK
#         aa_from_NNK=$(python $HOME/work/scripts/PDBchecker/find_top_mut_at_posi.py $posi $NNKfile "C")
#         echo "changing to $aa_at_posi to $aa_from_NNK at $posi" >> SECTION_I.log

#         # Mutate if the amino acid at the given position matches aa_old
#         if [ "$aa_at_posi" = "C" ]
#         then
#             # Replace the character at the specified position
#             seq="${seq:0:posi-1}$aa_from_NNK${seq:posi}"
#         else
#             echo "$p"
#             echo "Cysteine not found at position $((aa_at_posi + 1))"
#         fi
#     done

#     # check for even number of cysteines
#     c_count=$(echo "$seq" | tr -cd 'C' | wc -c)
#     if [ $((c_count % 2)) -eq 0 ]; then
#         echo ">${p::-4}" > "updated_fas/${p::-4}.fasta"
#         echo "$seq" >> "updated_fas/${p::-4}.fasta"
#     else
#         echo "$p"
#         echo "Odd number of Cysteines"
#     fi
# done

# ### SECTION II: FIND ADDED SEQUONS ###

# > sequons.csv

# # finds sequons
# for p in *pdb
# do
#     seq=$(sed -n '2p' "updated_fas/${p::-4}.fasta")
#     python $HOME/work/scripts/helper/pdb2sequon.py $p $seq >> sequons.csv
# done

# positions=()

# # finds unique sequons
# # Loop through each line in the CSV file
# while IFS=',' read -r filename sequons; do
#     sequon_array=($sequons)
#     for s in "${sequon_array[@]}"
#     do
#         if [[ ! " ${positions[@]} " =~ " $s " ]]
#         then
#             positions+=($s)
#         fi
#     done
# done < sequons.csv

# # Print the unique positions separated by '+'
# # convert to 1-index
# for i in "${!positions[@]}"
# do
#     # Use arithmetic expansion to add one to each position
#     positions[$i]=$((positions[$i] + 1))
# done

# # Join the elements of the modified positions array with '+' delimiter
# positions_string=$(IFS=+; echo "${positions[*]}")

# # Print the updated positions string
# echo "All sequons: $positions_string" > SECTION_II.log

# ### SECTION III: FIND DELETED SEQUONS ###

# > SECTION_III.log

# # finds missing sequons
# for posi in "${positions[@]}"; do
    
#     name_array=()
    
#     # Loop through each line in the CSV file
#     while IFS=',' read -r filename sequons; do
#         sequon_array=($sequons)
#         if [[ ! " ${sequon_array[*]} " =~ " $((posi - 1)) " ]]; then
#             name_array+=("$filename")
#         fi
#     done < sequons.csv

#     echo "list of pdb missing sequon at posi $posi" >> SECTION_III.log
#     for name in "${name_array[@]}"; do
#         echo "$name" >> SECTION_III.log
#     done

# done

# mkdir final_fas
# cp updated_fas/*.fasta final_fas

### SECTION IV: MUTATE ###

### WARNING ###
# SECTION I outputs 1-index of N
# sequons.csv contains 0-index of N

# aa_old=("N")
# # use 1-index
# aa_posi=(148)

# > SECTION_IV.log

# for p in *pdb
# do
#     NNKpath=$(echo "$p" | sed 's/\(.*0001\).*/\1/')
#     NNKfile="$HOME/work/workspace/H3RBS/esm/$NNKpath/output.csv"

#     seq=$(sed -n '2p' "final_fas/${p::-4}.fasta")

#     for ((i=0; i<${#aa_posi[@]}; i++))
#     do
#         posi=${aa_posi[i]}
#         aa_o=${aa_old[i]}

#         # Extract the character at the specified position
#         aa_at_posi="${seq:posi-1:1}"

#         # Mutate if the amino acid at the given position matches aa_old
#         if [ "$aa_at_posi" = "$aa_o" ]
#         then
#             # Replace the character at the specified position
#             aa_from_NNK=$(python $HOME/work/scripts/PDBchecker/find_top_mut_at_posi.py $posi $NNKfile "CNST")
#             seq="${seq:0:posi-1}$aa_from_NNK${seq:posi}"
#             # Replace the second line of the FASTA file with the mutated sequence
#             sed -i "2s/.*/$seq/" final_fas/${p::-4}.fasta
#             echo "changing to $aa_at_posi to $aa_from_NNK at $posi" >> SECTION_IV.log
#         else
#             echo "$aa_at_posi != $aa_o @ $posi"
#         fi
#     done
# done

# echo "done"