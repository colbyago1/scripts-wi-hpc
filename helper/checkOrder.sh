#!/bin/bash

file1="$1"
file2="$2"

# Remove ^M characters from file1 and file2
tr -d '\r' < "$file1" > "${file1::-4}_cleaned.csv"
tr -d '\r' < "$file2" > "${file2::-4}_cleaned.csv"

file1="${file1::-4}_cleaned.csv"
file2="${file2::-4}_cleaned.csv"

# Function to calculate the differences between two strings
get_difference() {
    local str1="$1"
    local str2="$2"
    
    local len1="${#str1}"
    local len2="${#str2}"
    
    local min_len=$((len1 < len2 ? len1 : len2))
    local differences=0
    
    for ((i = 0; i < min_len; i++)); do
        if [ "${str1:i:1}" != "${str2:i:1}" ]; then
            ((differences++))
        fi
    done

    echo "$differences"
}

match_found=0

echo "name1,name2,value1,value2,diff" > output.csv

# Read files line by line, starting from the second line
while IFS=, read -r name1 value1 || [ -n "$name1" ] && [ -n "$value1" ]; do
    match_found=0
    min_diff=
    closest_name=
    min_diff_value=


    # Read the second file, starting from the second line
    while IFS=, read -r name2 value2 || [ -n "$name2" ] && [ -n "$value2" ]; do
        # Compare values
        if [ "$value1" == "$value2" ]; then
            match_found=1
            echo "Match found for $name1"
            echo "$name1,$name2,$value1,$value2,0" >> output.csv
            break
        else
            # Calculate differences
            differences=$(get_difference "$value1" "$value2")

            # Find the name with the least differences
            if [ -z "$min_diff" ] || [ "$differences" -lt "$min_diff" ]; then
                min_diff="$differences"
                closest_name="$name2"
                min_diff_value="$value2"
            fi
        fi
    done < <(tail -n +2 "$file2")

    # Report results
    if [ "$match_found" -eq 0 ]; then
        echo "No match found for $name1"
        echo "Closest match found for $name1 with $min_diff differences."
        echo "$name1,$closest_name,$value1,$value2,$min_diff" >> output.csv
        $HOME/work/scripts/helper/seqs2muts.sh "$value1" "$min_diff_value"
    fi

done < <(tail -n +2 "$file1")

rm "$file1"
rm "$file2"