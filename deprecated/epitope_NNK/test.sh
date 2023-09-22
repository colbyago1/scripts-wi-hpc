#!/bin/sh

name="$1"
seq=$(sed -n '2p' "$name.fasta")
echo "$seq"

# alignMolecules prep

#### define epitopes ###
substrings=("CYKY" "TQNGTSSAC" "WLTHLNY" "HHPGTDKDQIFL" "IPSRI")
mutations=("CY**" "T*NGTSS**" "W*TH*NY" "H******D**FL" "I****")

### Find epitope locations in wt sequences ###

pdb_file="$HOME/work/workspace/H3RBS/rosettaLeads/relaxed/$name.pdb"

# Initialize an empty array to store positions
position_strings=()
mutate_positions=()
selection=()

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

for string in "${position_strings[@]}"
do
    selection+=" --sele2 name CA and resi $string"
done

echo "$selection"

# debug
echo "rmsd"
index=1
# rmsd calculation
cd "structures_$index"

reference="$HOME/work/workspace/H3RBS/epitope.pdb"

# remove first line from $2 and store in header
header=$(cat "../output_$index.csv" | head -n 1)
content=$(cat "../output_$index.csv" | sed '1d')

# Create a temporary file to store content for splitting
temp_file=$(mktemp)

# Save the content to the temporary file
echo "$content" > "$temp_file"

# Split the temporary file into multiple smaller files
split -l 100 "$temp_file" tmp_split_rmsd_

# Clean up the temporary file
rm "$temp_file"

# Array to store job IDs
job_ids=()

for file in tmp_split_rmsd_*
do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    job_id=$(/wistar/kulp/software/slurmq --sbatch "/home/cagostino/work/scripts/epitope_NNK/rmsd_alignMolecules.sh $reference $file '$selection'" | awk '/Submitted batch job/ {print $4}')
    job_ids+=("$job_id")
done

echo "hi"
mkdir debug
for job_id in "${job_ids[@]}"
    do
        while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
        do
            sleep 1
        done
        mv "slurm-$job_id.out" debug
    done

echo "$header,rmsd" > "../output_rmsd_$index.csv"
cat tmp_split_rmsd_*.output.csv >> "../output_rmsd_$index.csv"
rm tmp_split_rmsd_*

cd ..