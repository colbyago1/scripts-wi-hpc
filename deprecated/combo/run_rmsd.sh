#!/bin/bash

reference="$1"

# remove first line from $2 and store in header
header=$(cat "$2" | head -n 1)
content=$(cat "$2" | sed '1d')

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
    job_id=$(/wistar/kulp/software/slurmq --sbatch "/home/cagostino/work/scripts/combo/rmsd_alignMolecules.sh $reference $file $3" | awk '/Submitted batch job/ {print $4}')
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

echo "$header,rmsd" > "../output_rmsd_$3.csv"
cat tmp_split_rmsd_*.output.csv >> "../output_rmsd_$3.csv"
rm tmp_split_rmsd_*
