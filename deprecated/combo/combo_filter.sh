#!/bin/sh

# Improvements
# 1. Add rmsd section
# 2. Sort out duplicates earlier
# 3. Add module to take all mutations better than wt
# 4. Combine mutant combinations in one loop with conditional control

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

index=1
name="$1"
seq=$(sed -n '2p' "$1.fasta")
echo "$seq"
mkdir slurms
mkdir fas

while [ $index -lt 5 ]; do
    #debug
    echo "index = $index"

    # Initialize the muts array as an empty array
    declare -a muts_combinations=()

    if [ $index -eq 1 ]; then
        # two-element combination
        for element1 in "${muts[@]}"; do
            for element2 in "${muts[@]}"; do
                muts_combinations+=("$element1 $element2")  # Add the elements as a two-element combination
            done
        done
    else
        # additional combinations
        for combo in "${top_combinations[@]}"; do
            for element in "${muts[@]}"; do
                muts_combinations+=("$combo $element")
            done
        done
    fi

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

        # Use grep with a regular expression to extract numeric parts, then sort and use uniq to find duplicates
        duplicates=$(echo "$combo" | grep -oE '[0-9]+' | sort | uniq -d)

        # Check if there are any duplicates
        if [ -z "$duplicates" ]; then
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
        fi
    done

    # Array to store job IDs
    job_ids=()

    # debug
    echo "NNK"

    # NNK
    for f in ./*fa
    do
        while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
            do
                sleep 1
            done
        # Submit the job and capture the job ID
        job_id=$(sbatch ~/work/scripts/combo/submit.sh "$f" "$index" | awk '{print $4}')
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
        # rm "slurm-$job_id.out"
    done

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
    /home/cagostino/work/scripts/combo/run_rmsd.sh "$HOME/work/workspace/H3RBS/epitope.pdb" "../output_$index.csv" "$index"
    cd ..

    # debug
    echo "filter"

    # filter
    python /home/cagostino/work/scripts/combo/filter.py "output_rmsd_$index.csv"

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

