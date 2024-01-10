#!/bin/sh

depth=5 # number of mutations
partners="A_B"
pdb="$1"
CUTOFF_PERCENTAGE=0
positions=(163 164 165 232 233 234 238 239 296 321 323 324 325 326 332 334 337 338 339)
# no muts to C
aminos=(G A L M F W K Q E S P V I Y H R N D T)
relax=0
search_string=${pdb::-4}

mkdir rss
mkdir slurms
mkdir pdbs
mkdir csvs

muts=()
top_combos=()

# Loop through each position
for position in "${positions[@]}"; do
    # Loop through each amino acid
    for amino in "${aminos[@]}"; do
        # Concatenate the position and amino acid and add it to the combos array
        mut="${position}${amino}"
        muts+=("$mut")
    done
done

echo "muts: ${muts[@]}"

# WT
python /wistar/kulp/users/cagostino/scripts/rosetta/multibody/combo_NNK/mutate_wt.py "$pdb" "$partners"
read wt_unbound wt_nrg < "wt"

# init output.csv
echo "pdb,unbound nrg,ratio" > output.csv

index=0

while [ $index -lt $depth ]
do
    echo "index: $index"

    combos=()
    sorted_combos=()
    unique_combos=()

    if [ $index -gt 0 ]; then
        for top_combo in "${top_combos[@]}"; do
            for mut in "${muts[@]}"; do
                new_combo="$top_combo $mut"
                # Use grep with a regular expression to extract numeric parts, then sort and use uniq to find duplicates
                duplicates=$(echo "$new_combo" | grep -oE '[0-9]+' | sort | uniq -d)
                if [ -z "$duplicates" ]; then
                    combos+=("$new_combo")
                fi
            done
        done

        echo "combos: ${combos[@]}"

        # Initialize the muts array as an empty array
        declare -a sorted_combos=()

        for combo in "${combos[@]}"; do
            sort=$(echo "$combo" | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
            sorted_combos+=("$sort")
        done

        # Initialize the muts array as an empty array
        declare -a unique_combos=()

        # Loop through each element in the array
        for combo in "${sorted_combos[@]}"; do
            # Check if the element is not already in the uniqueStrings array
            if [[ ! " ${unique_combos[@]} " =~ " $combo " ]]; then
                # If not found, add it to the uniqueStrings array
                unique_combos+=("$combo")
            fi
        done

    else
        unique_combos=("${muts[@]}")
    fi

    # Array to store job IDs
    job_ids=()

    for combo in "${unique_combos[@]}"
    do
        while [ $(squeue -u cagostino -t pending | wc -l) -gt 50 ]
        do
            sleep 1
        done
        # Submit the job and capture the job ID
        job_id=$(/wistar/kulp/software/slurmq --sbatch "python /wistar/kulp/users/cagostino/scripts/rosetta/multibody/combo_NNK/mutate.py --pdb $pdb --partners $partners --wt_nrg $wt_nrg --index $index --relax $relax --mut $combo" | awk '/Submitted batch job/ {print $4}')
        job_ids+=("$job_id")
    done

    for job_id in "${job_ids[@]}"
    do
        while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
        do
            sleep 1
        done
        # rm "slurm-$job_id.out"
    done

    mv rs* rss
    mv slurm-* slurms

    top_designs=($(python /wistar/kulp/users/cagostino/scripts/rosetta/multibody/combo_NNK/find_top_designs.py "output_${index}.csv" $wt_unbound $((depth - index)) $CUTOFF_PERCENTAGE))

    top_combos=()
    for design in "${top_designs[@]}"; do
        echo $design
        combo=$(echo "$design" | sed "s/.*${search_string}_\([^\.]*\)\.pdb/\1/")
        echo "combo with underscore: $combo"
        combo="${combo//_/ }"
        echo "combo with space: $combo"
        top_combos+=("$combo")
    done

    echo "top combos: ${top_combos[@]}"

    mv "output_${index}.csv" csvs
    mv ${pdb::-4}_*.pdb pdbs

    # increment index
    ((index++))
done

echo "done"
