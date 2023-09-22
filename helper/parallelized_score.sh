#!/bin/bash

echo "$PWD"

# (1) For PDB in dir
echo "pdb" > PDBlist.csv
for p in *.pdb; do echo "$p" >> PDBlist.csv; done

# # # (2) for CC
# input_file="output.csv"
# > PDBlist.csv
# # Loop through each line in the input file
# while IFS=',' read -r val1 _; do
#     # Append the value of val1 to the output file
#     echo "$val1" >> PDBlist.csv
# done < "$input_file"

# (3) for esm
# run (1) but change cd $d to cd $d/structures and change cd .. to cd ../..

# remove first line from $2 and store in header
header=$(cat "PDBlist.csv" | head -n 1)
content=$(cat "PDBlist.csv" | sed '1d')

# Create a temporary file to store content for splitting
temp_file=$(mktemp)

# Save the content to the temporary file
echo "$content" > "$temp_file"

# Split the temporary file into multiple smaller files
split -l 100 "$temp_file" tmp_split_score_

# Clean up the temporary file
rm "$temp_file"

# Array to store job IDs
job_ids=()

for file in tmp_split_score_*
do
    mkdir "d_$file"
    # Read the input file line by line
    while IFS= read -r line; do
        # Move each file to the directory
        cp "$line" "d_$file/"
    done < "$file"
    cp $file "d_$file"
    echo "before cd into d_file $PWD"
    cd "d_$file"
    echo "after cd into d_file $PWD"

    while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    job_id=$(/wistar/kulp/software/slurmq --sbatch "/home/dwkulp/software/Rosetta/main/source/bin/score_jd2.linuxgccrelease -in:file:l $file" | awk '/Submitted batch job/ {print $4}')
    job_ids+=("$job_id")

    cd ..
    echo "cd back $PWD"
done

for job_id in "${job_ids[@]}"
    do
        while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
        do
            sleep 1
        done
        # rm "slurm-$job_id.out"
    done

first_file=true
for file in tmp_split_score_*
do
    if [ "$first_file" = true ]; then
        # If it's the first file, add the header
        head -n 2 "d_$file/score.sc" > score.sc
        first_file=false
    fi
    tail -n +3 "d_$file/score.sc" >> score.sc
done

rm tmp_split_score_*
rm d_tmp_split_score_* -r
echo "done"
