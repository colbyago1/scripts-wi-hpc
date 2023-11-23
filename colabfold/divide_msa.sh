#!/bin/bash

# Parses a3m file by contig
msa="$1"

# substrings to match (must be in order)
substrings=("NLWVTVYYGVPVWK" "KIEPLGVAPTRCKRR" "LGFLGAAGSTMGAASMTLTVQARNLLS" "GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD")
seq=$(sed -n '2p' $msa)
# echo $seq

# calculate start positions of contigs in sequence
starts=()
ends=()
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
        starts+=("${positions[0]}")
        # Calculate the ending position 
        ends+=("$((positions[0] + ${#substring}))")
    fi
done

# echo "${starts[@]}"
# echo "${ends[@]}"

# saves target names and target sequences to file
> target_names.txt
index=0
# tail is sensitive to input MSA!!!!!!!!!!!!!
tail -n +3 $msa | while IFS= read -r line; do
    # saves target names  to file
    if [ $((index % 2)) -eq 0 ]; then
        echo "$line" >> target_names.txt
    # saves target sequences to file
    else
        # Initialize
        counter=0
        saved_position=0
        found=0

        # Loop over each character in the input string
        for ((i = 0; i < ${#line}; i++)); do
            char="${line:i:1}"  # Get the current character

            # if substrings start is found, save position
            if [[ " ${starts[@]} " =~ " $counter " && ( "$char" == "-" || "$char" == [A-Z] ) ]]; then
                saved_position=$i
            # if substrings end is found, echo substring
            elif [[ " ${ends[@]} " =~ " $counter " && ( "$char" == "-" || "$char" == [A-Z] ) ]]; then
                echo "${line:saved_position:((i - saved_position))}" >> ${substrings[found]}.txt
                (( found++ ))
            fi
            # Check if the character is a dash or an uppercase letter
            if [[ "$char" == "-" || "$char" == [A-Z] ]]; then
                ((counter++))  # Increment the counter
            fi
        done
    fi
    ((index++))
done

### remove blank sequences ###

# length of a3m
line_count=$(wc -l < target_names.txt)

# length of substrings array
length=${#substrings[@]}
lines_to_remove=()
# Loop through textfiles and create sequences for msa by combining parsed a3m and linkers in order
for ((i = 1; i <= line_count; i++)); do
    non_dash=0
    for ((j = 0; j < length; j++)); do
        line=$(sed -n "${i}p" ${substrings[j]}.txt)
        echo "$line" >> check_sed.txt
        if [[ $line =~ [a-zA-Z] ]]; then
            non_dash=1
            break
        fi
    done
    if [[ $non_dash -eq 0 ]]; then
        lines_to_remove+=("$i")
        echo "rm" >> check_sed.txt
    fi
    echo >> check_sed.txt
done

semicolon_separated=$(IFS=";"; echo "${lines_to_remove[*]}")
sed_ready=$(echo "$semicolon_separated" | sed 's/;/d;/g')
sed_ready="${sed_ready}d"
# echo $sed_ready

# Replace in target_names.txt
sed -i -e "$sed_ready" target_names.txt

for ((j = 0; j < length; j++)); do
    # Replace in each ${substrings[j]}.txt file
    sed -e "$sed_ready" "${substrings[j]}.txt" > "${substrings[j]}_clean.txt"
done