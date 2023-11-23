#!/bin/bash

# makes a3m for pdb for hybrid msa colabfold
# run divide_msa first
msa_path="/home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/msa_data"
fa="$1"
# get sequence from chain A
seq=$(sed -n '2p' $fa)
length=${#seq}

# substrings to match
substrings=("NLWVTVYYGVPVWK" "KIEPLGVAPTRCKRR" "LGFLGAAGSTMGAASMTLTVQARNLLS" "GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD")

# find order of contigs
declare -A start_positions
starts=()
ends=()
sorted_substrings=()

# # monomer
# # write header and query to file
# echo -e "#${length}\t1" > ${fa::-3}.a3m
# echo ">101" >> ${fa::-3}.a3m
# echo "$seq" >> ${fa::-3}.a3m

# # multimer
# # write header and query to file
# echo -e "#${length}\t3" > ${fa::-3}.a3m
# echo ">101" >> ${fa::-3}.a3m
# echo "$seq" >> ${fa::-3}.a3m
# echo ">101" >> ${fa::-3}.a3m
# echo "$seq" >> ${fa::-3}.a3m

# loop through substrings
for substring in "${substrings[@]}"; do
    # Find positions of the substring
    positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

    # Check the length of positions array
    if [ "${#positions[@]}" -gt 1 ]; then
        echo "Warning: Multiple positions found for substring '$substring'"

    elif [ "${#positions[@]}" -lt 1 ]; then
        echo "Warning: No positions found for substring '$substring'"
    else
        # Get the first position
        position="${positions[0]}"

        # Add position to starts
        starts+=("$position")

        # Add position to associative array
        start_positions[$substring]=$position

        # Count the number of '[' characters in the substring
        bracket_count=$(echo "$substring" | tr -cd '[' | wc -c)

        # Calculate the ending position by subtracting 4 times the bracket count
        end_position=$((position + ${#substring} - 4 * bracket_count))

        # Add position to ends
        ends+=("$end_position")
    fi
done

# sort starts and ends
sorted_starts=($(for start in "${starts[@]}"; do echo "$start"; done | sort -n))
sorted_ends=($(for end in "${ends[@]}"; do echo "$end"; done | sort -n))


# Get length of linker regions (in order)
linker_lengths=()
length=${#sorted_starts[@]}
for ((i = 1; i < length; i++)); do
    start_i=${sorted_starts[i]}
    end_i_minus_1=${sorted_ends[i - 1]}
    difference=$((start_i - end_i_minus_1))
    linker_lengths+=("$difference")
done

# Make the linkers
linkers=()
for length in "${linker_lengths[@]}"; do
  dash_string=$(printf -- '-%.0s' $(seq 1 "$length"))
  linkers+=("$dash_string")
done

# Swap keys and values for sorting
declare -A position_index_map
for i in "${!start_positions[@]}"; do
    position="${start_positions[$i]}"
    position_index_map["$position"]=$i
done

# Sort the substrings by starting position
sorted_positions=($(echo "${start_positions[@]}" | tr ' ' '\n' | sort -n))

# Add substrings to sorted array
for position in "${sorted_positions[@]}"; do
    index="${position_index_map[$position]}"
    sorted_substrings+=("$index")
done

# length of a3m
line_count=$(wc -l < ${msa_path}/target_names_clean.txt)

# length of substrings array
length=${#sorted_substrings[@]}

# Loop through textfiles and create sequences for msa by combining parsed a3m and linkers in order
for ((i = 1; i <= line_count; i++)); do
    sed -n "${i}p" ${msa_path}/target_names_clean.txt >> ${fa::-3}.a3m
    line=
    for ((j = 0; j < length; j++)); do
        line+=$(sed -n "${i}p" ${msa_path}/${sorted_substrings[j]}_clean.txt)
        line+=${linkers[j]}
    done
    echo $line >> ${fa::-3}.a3m 
done

