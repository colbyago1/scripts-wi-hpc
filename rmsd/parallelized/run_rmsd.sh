#!/bin/bash

reference="$1"

# Split CSV file into multiple smaller CSV files
split -l 100 "$2" rmsd_

# Array to store job IDs
job_ids=()

for file in rmsd_*
do
    while [ $(squeue -u cagostino -t running,pending | wc -l) -gt 250 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    job_id=$(sbatch /home/cagostino/work/scripts/rmsd/parallelized/run.sh $reference $file | awk '{print $4}')
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

cat rmsd_*.output.csv >> output_rmsd.csv
rm rmsd_*
