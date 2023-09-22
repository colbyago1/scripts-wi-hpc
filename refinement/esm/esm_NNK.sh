#!/bin/bash

input_fasta="$1"

# no muts to cysteine
aminos=(G A L M F W K Q E S P V I Y H R N D T)
wt_seq=$(sed -n '2p' "$input_fasta")
seq_len=${#wt_seq}
posis=($(seq 1 $seq_len))

##################################################################
######################### Epitope module #########################
##################################################################

# * = mutatable
substrings=("CY[A-Z]Y" "TQNGTSSAC" "WLTHLNY" "HHPGTDKDQIFL" "IPSRI")
mutations=("CY**" "T*NGTSS**" "W*TH*NY" "H******D**FL" "I****")
pdb_file="$HOME/work/workspace/H3RBS/rosettaLeads/relaxed/$pdb.pdb"

# Initialize an empty array to store positions
position_strings=()
mutate_positions=()

index=0
# Loop through the substrings
for substring in "${substrings[@]}"; do
    # Find positions of the substring
    positions=($(echo "$wt_seq" | grep -bo "$substring" | cut -d':' -f1))

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

        for ((i = position + 1; i <= end_position; i++)); do
            # find mutate positions and store in array
            ((mutate_posi=$i-$position-1))
            if [ "${mutations[index]:$mutate_posi:1}" != "*" ]; then
                mutate_positions+=("$i")
            fi
        done
    fi
    # Increment the counter
    ((index++))
done

# mutate positions
echo "mutate positions"
echo "${mutate_positions[@]}"

##################################################################
##################################################################
##################################################################

for i in "${posis[@]}"
do
    if [[ -z "${mutate_positions[@]}" || ! " ${mutate_positions[@]} " =~ " $i " ]]; then
        for j in "${aminos[@]}"
        do
            # change the ith position of wt_seq to j
            if [[ $j != ${wt_seq:i-1:1} ]]
            then
                modified_seq=${wt_seq:0:i-1}$j${wt_seq:i}
                # echo "$modified_seq"
                output_file="${input_fasta:0:-6}_$i$j.fa"
                echo ">${input_fasta:0:-6}_$i$j" > "$output_file"
                echo "$modified_seq" >> "$output_file"
            fi
        done
    fi
done

for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
        do
        	sleep 1
        done
	sbatch ~/work/scripts/refinement/esm/submit.sh "$f"
done

