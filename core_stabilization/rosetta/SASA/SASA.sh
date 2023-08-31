#!/bin/sh

pdb="$1"
cutoff=0.3
aminos=(G A L M F W K Q E S P V I C Y H R N D T)

# calculate sasa
/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $pdb --reportByResidue --writePdb --writeNormSasa > sasa.log

# init csv
echo "resi,sasa" > sasa.csv

# Loop through the file line by line
while IFS= read -r line; do
    # Extract the first word
    first_word=$(echo "$line" | awk '{print $1}')

    # Check if the first word is 'A'
    if [ "$first_word" = "A" ]; then
        # Extract the second and fourth words
        resi=$(echo "$line" | awk '{print $2}')
        sasa=$(echo "$line" | awk '{print $5}')

        # Print or store the second and fourth words as needed
        echo "$resi,$sasa" >> sasa.csv
    fi
done < sasa.log

# init positions array
positions=()

# Read the file line by line using process substitution
while IFS=',' read -r resi sasa
do
    if (( $(echo "$sasa < $cutoff" | bc -l) ))
    then
        positions+=("$resi")
    fi
done < <(tail -n +2 "sasa.csv")

# Array to store job IDs
job_ids=()

echo "${positions[@]}"

# run mutate
for i in "${positions[@]}"
do
    for j in "${aminos[@]}"
    do
        while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
        do
            sleep 1
        done
        job_id=$(sbatch /home/cagostino/work/scripts/core_stabilization/rosetta/SASA/run_mutate.sh "$pdb" "$i" "$j" | awk '{print $4}')
        job_ids+=("$job_id")
    done
done

# wait for jobs to finish
for job_id in "${job_ids[@]}"
do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
done

