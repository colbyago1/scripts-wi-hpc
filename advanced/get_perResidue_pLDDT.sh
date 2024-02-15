#!/bin/bash

### WARNING: ONLY WORKS FOR CHAIN A!!! ###

# ID can be modified so that it is a number corresponding to an epitope
    # each contig could have a unique ID and be averaged
    # each residue from an epitope could have a unique ID for comparison across different scaffolds

file="$1"

# ### ID corresponds to chain + resi ###

# echo "file,chain,resi,resn,pLDDT,ID" > prpLDDT.csv
# cat $file | awk '/^ATOM/ && $3 == "CA" {print $5 "," $6 "," $4 "," $11 ",0"}' "$file" >> prpLDDT.csv

# substrings=("KVGGNYNYLYRLFRK" "TGKIA" "GFNCYFPLQSYGFQPTNGVGYQP")

# # get sequence (chain A)
# seq=$(cat $file | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')

# # get position of contigs and save to csv
# fixed_positions=()
# index=0
# counter=1
# # Loop through the substrings
# for substring in "${substrings[@]}"; do
#     # Find positions of the substring
#     positions=($(echo "$seq" | grep -bo "$substring" | cut -d':' -f1))

#     # Check the length of positions array
#     if [ "${#positions[@]}" -gt 1 ]; then
#         echo "Warning: Multiple positions found for substring '$substring'"

#     elif [ "${#positions[@]}" -lt 1 ]; then
#         echo "Warning: No positions found for substring '$substring'"
#     else
#         # Get the single position
#         position="${positions[0]}"

#         # Calculate the ending position
#         end_position=$((position + ${#substring}))

#         # Initialize an empty array to store positions
#         position_list=()
#         # Create an array of positions from start to end
#         for ((i = position + 1; i <= end_position; i++)); do
#             position_list+=("$i")
#             awk -i inplace -v posi="$i" -v idx="$counter" -F',' '$2 == posi {OFS=","; $5=$1 idx}1' prpLDDT.csv
#             ((counter++))
#             # Echo the letter at that position
#             # letter=$(echo "$seq" | cut -c "$i")
#             # echo "Position $i: $letter"
#         done
#         fixed_positions+=("${position_list[*]}")
#     fi
#     # Increment the counter
#     ((index++))
# done

# sed -i '1!s/^/'"$file"',/' prpLDDT.csv

### ID corresponds to contig (0 = not in epitope) ###
echo "file,chain,resi,resn,pLDDT,ID" > prpLDDT.csv
cat $file | awk '/^ATOM/ && $3 == "CA" {print $5 "," $6 "," $4 "," $11 ",0"}' "$file" >> prpLDDT.csv

substrings=("KVGGNYNYLYRLFRK" "TGKIA" "GFNCYFPLQSYGFQPTNGVGYQP")

# get sequence (chain A)
seq=$(cat $file | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')

# get position of contigs and save to csv
fixed_positions=()
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

        # Calculate the ending position
        end_position=$((position + ${#substring}))

        # Initialize an empty array to store positions
        position_list=()
        # Create an array of positions from start to end
        for ((i = position + 1; i <= end_position; i++)); do
            position_list+=("$i")
            awk -i inplace -v posi="$i" -v idx="$((index + 1))" -F',' '$2 == posi {OFS=","; $5=$1 idx}1' prpLDDT.csv
            # Echo the letter at that position
            # letter=$(echo "$seq" | cut -c "$i")
            # echo "Position $i: $letter"
        done
        fixed_positions+=("${position_list[*]}")
    fi
    # Increment the counter
    ((index++))
done

sed -i '1!s/^/'"$file"',/' prpLDDT.csv