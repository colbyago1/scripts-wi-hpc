#!/bin/sh

p="$1"
Ab=$2
posis=("${@:3}")

for posi in "${posis[@]}"; do

    AbSASA=
    totalSASA=

    # get SASA from complex
    while read -r line; do
        # Extract the first and second words using awk
        chain=$(echo "$line" | awk '{print $1}')
        position=$(echo "$line" | awk '{print $2}')

        # Check if the first word is "$Ab" and the second word is "$posi"
        if [[ "$chain" == "$Ab" && "$position" == "$posi" ]]; then
            # Split the line into an array of words
            totalSASA=$(echo "$line" | awk '{print $4}')
        fi
    done < ${p::-4}_SASA_total.txt

    # get SASA from Ab
    while read -r line; do
        # Extract the first and second words using awk
        chain=$(echo "$line" | awk '{print $1}')
        position=$(echo "$line" | awk '{print $2}')

        # Check if the first word is "$Ab" and the second word is "$posi"
        if [[ "$chain" == "$Ab" && "$position" == "$posi" ]]; then
            # Split the line into an array of words
            AbSASA=$(echo "$line" | awk '{print $4}')
        fi
    done < ${p::-4}_SASA_Ab.txt

    diffSASA=$(echo "$AbSASA - $totalSASA" | bc)

    echo "$p,$posi,$AbSASA,$totalSASA,$diffSASA" >> "${p::-4}_posi${posi}_SASA_hotspot.csv"
done
