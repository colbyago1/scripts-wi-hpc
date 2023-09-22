#!/bin/bash

pdb="$1"

#### define epitopes ###
substrings=("CYPY" "TQNGTSSAC" "WLTHLNY" "HHPGTDKDQIFL" "IPSRI")
mutations=("CY**" "T*NGTSS**" "W*TH*NY" "H******D**FL" "I****")

### Find epitope locations in wt sequences ###

pdb_file="$HOME/work/workspace/H3RBS/rosettaLeads/relaxed/$pdb.pdb"

seq=$(python /home/cagostino/work/scripts/helper/pdb2seq.py "$pdb_file")

# Initialize an empty array to store positions
position_strings=()
mutate_positions=()

index=0
# Loop through the substrings
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
        position="${positions[0]}"

        # Count the number of '[' characters in the substring
        bracket_count=$(echo "$substring" | tr -cd '[' | wc -c)

        # Calculate the ending position by subtracting 4 times the bracket count
        end_position=$((position + ${#substring} - 4 * bracket_count))

        # Initialize an empty array to store positions
        position_list=()
        # Create an array of positions from start to end
        for ((i = position + 1; i <= end_position; i++)); do
            position_list+=("$i")
            # Echo the letter at that position
            letter=$(echo "$seq" | cut -c "$i")
            echo "Position $i: $letter"

            # find mutate positions and store in array
            ((mutate_posi=$i-$position-1))
            if [ "${mutations[index]:$mutate_posi:1}" == "*" ]; then
                mutate_positions+=("$i")
            fi

        done
        position_string=$(IFS=+; echo "${position_list[*]}")
        position_strings+=("$position_string")
    fi
    # Increment the counter
    ((index++))
done

# alignMolecule strings
echo "position strings"
for p in "${position_strings[@]}"
do
    echo $p
done

# mutate positions
echo "mutate positions"
echo "${mutate_positions[@]}"

# ### Find NNK information for each position ###

NNK_file="$HOME/work/workspace/H3RBS/esm/$pdb/output.csv"

echo "description,pLDDT,pTM" > output.csv

while IFS= read -r line; do
    # if line contains "$pdb_num(number from mutate_positions)[A-Z].pdb" add line to called output.csv
    # Extract numbers between $pdb and [A-Z]
    posi=$(echo "$line" | grep -oP "(?<=${pdb}_)[0-9]+(?=[A-Z])")

    # Check if the number exists in the mutate_positions array
    if [[ " ${mutate_positions[@]} " =~ " $posi " ]]; then
        # Add the line to the output file
        echo "$line" >> output.csv
    fi
done < "$NNK_file"

# ### Calculation RMSD for each position ###

NNK="$HOME/work/workspace/H3RBS/esm/$pdb/structures/"
reference="/home/cagostino/work/workspace/H3RBS/epitope.pdb"

# Process the first line separately to add the "rmsd" header
IFS='' read -r header < output.csv
new_header="$header,rmsd"
echo "$new_header" > output_rmsd.csv

for string in "${position_strings[@]}"
do
    selection+=" --sele2 name CA and resi $string"
done

# Loop through each line in the CSV file
tail -n +2 output.csv | while IFS=',' read -r pdb_filename rest_of_line; do
    if [ -e "$NNK/$pdb_filename" ]
    then
        # Run the Python script and capture its output
        output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 $NNK/$pdb_filename --sele1 name CA$selection --noOutputPdb)
        # Extract the last word from the output using awk
        rmsd=$(echo "$output" | awk '/RMSD/{print $2}')
        
        if [ -z "$rmsd" ]; then
            rmsd=100.0
        fi

        # Append the RMSD value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$rmsd"
    else
        # If 'p' doesn't match, keep the line unchanged
        new_line="$pdb_filename,$rest_of_line"
    fi
    # Write the new line to a temporary file
    new_line="${new_line//,,/,}"
    echo "$new_line" >> "output_rmsd.csv"
done

# ### Output ###

