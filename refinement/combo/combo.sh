#!/bin/sh

# Define variables
substrings=("CY[A-Z]Y" "TQNGTSSAC" "WLTHLNY" "HHPGTDKDQIFL" "IPSRI")
reference="$HOME/work/workspace/H3RBS/epitope.pdb"
name="$1"
seq=$(sed -n '2p' "$1.fasta")
pdb_file="$HOME/work/workspace/H3RBS/rosettaLeads/relaxed/$name.pdb"
cycles=3
filter_method="rel" # rel or alg
wt_rmsd=2.7
wt_plddt=73
# set other filter parameters

# Initialize the CC_muts array as an empty array of arrays
declare -a CC_muts=()

# Loop through files in the CC directory and extract mutation information
for p in CC/*
do
    mutation_info=$(echo "$p" | grep -oP 'C\d+' | tail -2 | xargs -n2)
    # Check if the mutation_info is already in CC_muts before appending
    if [[ ! " ${CC_muts[*]} " =~ " $mutation_info " ]]; then
        CC_muts+=("${mutation_info[@]}")
    fi
done

# Initialize the esm_NNK_muts array as an empty array of arrays
declare -a esm_NNK_muts=()

# Loop through files in the esm_NNK directory and extract mutation information
for p in esm_NNK/*
do
    mutation_info=$(echo "$p" | grep -oP '_\K[^_.]+(?=\.)')
    mutation_info="${mutation_info: -1}${mutation_info:0:-1}"
    
    # Check if the mutation_info is already in esm_NNK_muts before appending
    if [[ ! " ${esm_NNK_muts[*]} " =~ " $mutation_info " ]]; then
        esm_NNK_muts+=("${mutation_info[@]}")
    fi
done

# Initialize the muts array as an empty array of arrays
declare -a muts=()

# Add the elements of CC_muts to muts individually
for element in "${CC_muts[@]}"; do
    muts+=("$element")
done

# Add the elements of esm_NNK_muts to muts individually
for element in "${esm_NNK_muts[@]}"; do
    muts+=("$element")
done

# Print the mutations, now as arrays of arrays
echo "CC_muts: ${CC_muts[@]}"
echo "esm_NNK_muts: ${esm_NNK_muts[@]}"
echo "muts: ${muts[@]}"

echo "$seq"

mkdir slurms
mkdir fas

# Initialize an empty array to store positions
position_strings=()
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

index=1
top_combinations=("${muts[@]}")

while [ $index -lt $cycles ]; do
    #debug
    echo "index = $index"

    # Initialize the muts array as an empty array
    declare -a muts_combinations=()

    # additional combinations
    for combo in "${top_combinations[@]}"; do
        for element in "${muts[@]}"; do
            new_combo="$combo $element"
            # Use grep with a regular expression to extract numeric parts, then sort and use uniq to find duplicates
            duplicates=$(echo "$new_combo" | grep -oE '[0-9]+' | sort | uniq -d)
            if [ -z "$duplicates" ]; then
                muts_combinations+=("$new_combo")
            fi
        done
    done

    # Initialize the muts array as an empty array
    declare -a sorted_muts=()

    for combo in "${muts_combinations[@]}"; do
        sort=$(echo "$combo" | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
        sorted_muts+=("$sort")
    done

    for combo in "${sorted_muts[@]}"; do
        echo "sort: $combo"
    done

    # Initialize the muts array as an empty array
    declare -a unique_muts=()

    # Loop through each element in the array
    for combo in "${sorted_muts[@]}"; do
        # Check if the element is not already in the uniqueStrings array
        if [[ ! " ${unique_muts[@]} " =~ " $combo " ]]; then
            # If not found, add it to the uniqueStrings array
            unique_muts+=("$combo")
        fi
    done

    for combo in "${unique_muts[@]}"; do
        echo "uni: $combo"
    done

    # Make fastas

    for combo in "${unique_muts[@]}"; do
        mutSeq=$seq

        echo "$combo"

        # Use parameter expansion to split the string into words
        combo_array=($combo)

        # Loop through each mut
        for mut in "${combo_array[@]}"; do
            amino="${mut:0:1}"
            posi="${mut:1}"
            mutSeq="${mutSeq:0:$posi-1}$amino${mutSeq:posi}"
        done

        echo ">${name}_${combo// /_}" > "${name}_${combo// /_}.fa"
        echo "$mutSeq" >> "${name}_${combo// /_}.fa"

    done

    # Array to store job IDs
    job_ids=()

    # debug
    echo "NNK"

    # NNK
    for f in ./*fa
    do
        while [ $(squeue -u cagostino -t pending | wc -l) -gt 50 ]
            do
                sleep 1
            done
        # Submit the job and capture the job ID
        job_id=$(sbatch ~/work/scripts/refinement/combo/submit.sh "$f" "$index" | awk '{print $4}')
        job_ids+=("$job_id")
    done

    # debug
    echo "wait"

    # wait
    for job_id in "${job_ids[@]}"
    do
        while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
        do
            sleep 1
        done
    done

    # debug
    echo "mv fas"

    # mv fas
    for f in ./*fa
    do
        mv $f fas
    done

    # Create the CSV file and write header
    echo "description,pLDDT,pTM" > output_$index.csv

    # debug
    echo "extract metrics"

    # Loop through the files
    for filename in slurm-*.out; do
        if [ -f "$filename" ]; then
            while read -r line; do
                if [[ "$line" =~ Predicted\ structure\ for\ ([^[:space:]]+)\ with\ length\ [[:digit:]]+,\ pLDDT\ ([[:digit:].]+),\ pTM\ ([[:digit:].]+)\ in ]]; then
                    protein_name="${BASH_REMATCH[1]}.pdb"
                    pLDDT="${BASH_REMATCH[2]}"
                    pTM="${BASH_REMATCH[3]}"
                    echo "$protein_name,$pLDDT,$pTM" >> output_$index.csv
                fi
            done < "$filename"
        fi
    done

    # debug
    echo "mv slurms"

    # mv slurms
    for job_id in "${job_ids[@]}"
    do
        mv "slurm-$job_id.out" slurms
    done

    # debug
    echo "rmsd"

    # rmsd calculation
    cd "structures_$index"

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
        while [ $(squeue -u cagostino -t pending | wc -l) -gt 50 ]
        do
            sleep 1
        done
        # Submit the job and capture the job ID
        job_id=$(/wistar/kulp/software/slurmq --sbatch "/home/cagostino/work/scripts/refinement/combo/rmsd_alignMolecules.sh $reference $file '$selection'" | awk '/Submitted batch job/ {print $4}')
        job_ids+=("$job_id")
    done

    for job_id in "${job_ids[@]}"
        do
            while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
            do
                sleep 1
            done
            rm "slurm-$job_id.out"
        done

    echo "$header,rmsd" > "../output_rmsd_$index.csv"
    cat tmp_split_rmsd_*.output.csv >> "../output_rmsd_$index.csv"
    rm tmp_split_rmsd_*

    cd ..

    # debug
    echo "filter"

    if [ "$filter_method" = "alg" ]; then
        # filter (based on combo algorithm)
        python /home/cagostino/work/scripts/refinement/combo/filter_alg.py "output_rmsd_$index.csv"
    fi

    if [ "$filter_method" = "rel" ]; then
        # filter (based on relative scores)
        python /home/cagostino/work/scripts/refinement/combo/filter_rel.py "output_rmsd_$index.csv" $wt_rmsd $wt_plddt
    fi

    # get new muts_combinations
    top_combinations=()

    # debug
    echo "top combos"

    while read -r line; do
        
        # Use parameter expansion to get everything after the last "0001_"
        line="${line##*0001_}"

        # Replace underscores with spaces
        line=${line::-4}

        # Replace underscores with spaces
        line="${line//_/ }"

        # debug
        echo "$line"

        # add to muts_combinations
        top_combinations+=("$line")

    done <  filtered_$index.csv

    # increment
    index=$((index + 1))
done

head -n 1 output_rmsd_1.csv > output_rmsd.csv
tail -n +2 output_rmsd_*.csv >> output_rmsd.csv

echo "done"

