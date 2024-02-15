#!/bin/bash


# path to msas directory
path="$1"

# added functionality to include all AF msas
~/work/scripts/reformat.pl sto a3m $path/uniref90_hits.sto uniref90.a3m
~/work/scripts/reformat.pl sto a3m $path/mgnify_hits.sto mgnify.a3m
~/work/scripts/reformat.pl a3m a3m $path/bfd_uniclust_hits.a3m bfd_uniclust.a3m

awk '/^>/ {if (seq) print seq; printf "%s\n", $0; seq = ""; next} {gsub(/[ \t\r\n]/,""); seq = seq $0} END {if (seq) print seq}' uniref90.a3m > uniref90_reformatted.a3m
awk '/^>/ {if (seq) print seq; printf "%s\n", $0; seq = ""; next} {gsub(/[ \t\r\n]/,""); seq = seq $0} END {if (seq) print seq}' mgnify.a3m > mgnify_reformatted.a3m
awk '/^>/ {if (seq) print seq; printf "%s\n", $0; seq = ""; next} {gsub(/[ \t\r\n]/,""); seq = seq $0} END {if (seq) print seq}' bfd_uniclust.a3m > bfd_uniclust_reformatted.a3m

cat bfd_uniclust_reformatted.a3m > msa.a3m
tail -n +3 uniref90_reformatted.a3m >> msa.a3m
tail -n +3 mgnify_reformatted.a3m >> msa.a3m

# Parses a3m file by contig
msa=msa.a3m

# substrings to match (must be in order)
substrings=("TGKIA" "KVGGNYNYLYRLFRK" "GFNCYFPLQSYGFQPTNGVGYQP")
seq=$(sed -n '2p' $msa)
# echo $seq

# Check lengths
length=$(echo $seq | tr -cd 'A-Z-' | wc -c)
awk -v length_var="$length" 'NR % 2 == 0 { gsub(/[^A-Z-]/, ""); count = length; if (count != length_var) print "count != length" }' msa.a3m

# calculate start positions of contigs in sequence
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

# echo "${starts[@]}"
# echo "${ends[@]}"

# saves target names and target sequences to file
> target_names.txt
index=0
# tail is sensitive to input MSA (i.e. colabfold MSA has a different header)
tail -n +3 $msa | while IFS= read -r line; do
    # saves target names  to file
    if [ $((index % 2)) -eq 0 ]; then
        echo "$line" >> target_names.txt
        # echo "$line"
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
                checkSum=$(echo $((i - $(echo "${line:0:i}" | tr -cd '[:lower:]' | wc -c))))

                # ensure start is correct
                if [ "${starts[found]}" != "$checkSum" ]; then
                    echo "Element "${starts[found]}" is not equal to $checkSum"
                fi

            # if substrings end is found, echo substring
            elif [[ " ${ends[@]} " =~ " $counter " && ( "$char" == "-" || "$char" == [A-Z] ) ]]; then
                echo "${line:saved_position:((i - saved_position))}" >> ${substrings[found]}.txt
                checkSum=$(echo $(($(echo "${line:saved_position:((i - saved_position))}" | wc -c) - $(echo "${line:saved_position:((i - saved_position))}" | tr -cd '[:lower:]' | wc -c)-1)))
                # ensure length is correct
                if [ ${#substrings[found]} != "$checkSum" ]; then
                    echo "Element ${#substrings[found]} is not equal to $checkSum"
                fi
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
echo line count = $line_count

# length of substrings array
length=${#substrings[@]}
echo length = $length
lines_to_remove=()
# Loop through textfiles and create sequences for msa by combining parsed a3m and linkers in order
for ((i = 1; i <= line_count; i++)); do
    non_dash=0
    for ((j = 0; j < length; j++)); do
        line=$(sed -n "${i}p" ${substrings[j]}.txt)
        echo "$line" >> check_sed.txt
        if [[ $line =~ [A-WYZ] ]]; then
            non_dash=1
            break
        fi
    done
    if [[ $non_dash -eq 0 ]]; then
        lines_to_remove+=("$i")
        echo "rm" >> check_sed.txt
        echo rm $i
    fi
    echo >> check_sed.txt
done

echo lines_to_remove = "${lines_to_remove[*]}"

if [ "${#lines_to_remove[@]}" -ne 0 ]; then
    semicolon_separated=$(IFS=";"; echo "${lines_to_remove[*]}")
    sed_ready=$(echo "$semicolon_separated" | sed 's/;/d;/g')
    sed_ready="${sed_ready}d"
    echo $sed_ready

    # Replace in target_names.txt
    sed -i -e "$sed_ready" target_names.txt

    for ((j = 0; j < length; j++)); do
        # Replace in each ${substrings[j]}.txt file
        sed -i -e "$sed_ready" "${substrings[j]}.txt"
    done
fi