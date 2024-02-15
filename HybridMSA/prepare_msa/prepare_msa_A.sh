#!/bin/bash

# makes a3m for pdb for hybrid msa colabfold
# run divide_msa first
msa_path="/home/cagostino/work/workspace/method_validation/hybridMSA/HybridMSA/SARS-CoV-2-RBD_monomer"
fa="$1"
# get sequence from chain A
seq=$(sed -n '2p' $fa)
length=${#seq}

# substrings to match
substrings=("TGKIA" "KVGGNYNYLYRLFRK" "GFNCYFPLQSYGFQPTNGVGYQP")

# find order of contigs
declare -A start_positions
starts=()
ends=()
sorted_substrings=()

# this is now handled by prepare_msa_B
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


# get position list from align.csv
# check if position is in positions and save that position to index 0
positions_from_file=$(grep  ${fa::-6}.pdb ../../align.csv | awk -F, '{print $2}')

# loop through substrings
for substring in "${substrings[@]}"; do
    # Find positions of the substring
    positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

    # Check the length of positions array
    if [ "${#positions[@]}" -gt 1 ]; then
        echo "Warning: Multiple positions found for substring '$substring'" >> error.log

        # Loop through each value in positions array
        for pos in "${positions[@]}"; do
            # Check if the current value exists in positions_from_file array
            if [[ " ${positions_from_file[*]} " == *" $pos "* ]]; then
                positions[0]=$pos  # Set positions[0] to the matching value
                echo "Resolved"
                break  # Break the loop once a match is found
            fi
        done

    elif [ "${#positions[@]}" -lt 1 ]; then
        echo "Warning: No positions found for substring '$substring'" >> error.log
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

# get length of amino linker
first_start="${sorted_starts[0]}"
Nlinker=$first_start
Nlinker_dash_string=$(printf -- '-%.0s' $(seq 1 "$Nlinker"))

# get length of carboxyl linker
last_end="${sorted_ends[-1]}"
Clinker=$((length - last_end))
Clinker_dash_string=$(printf -- '-%.0s' $(seq 1 "$Clinker"))

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
line_count=$(wc -l < ${msa_path}/target_names.txt)

# length of substrings array
length=${#sorted_substrings[@]}

> ${fa::-6}.a3m
# Loop through textfiles and create sequences for msa by combining parsed a3m and linkers in order
for ((i = 1; i <= line_count; i++)); do
    sed -n "${i}p" ${msa_path}/target_names.txt >> ${fa::-6}.a3m
    line=$Nlinker_dash_string
    for ((j = 0; j < length; j++)); do
        line+=$(sed -n "${i}p" ${msa_path}/${sorted_substrings[j]}.txt)
        line+=${linkers[j]}
    done
    line+=$Clinker_dash_string
    checkSum=$((${#line} - $(echo "$line" | tr -cd '[:lower:]' | wc -c)))
    if [ ${checkSum} = ${#seq} ]; then
        echo $line >> ${fa::-6}.a3m 
    else
        echo ${checkSum} is not equal to ${#seq} >> error.log
    fi
done