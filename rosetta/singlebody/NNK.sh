#!/bin/sh

# run singlebody mutate on proteins of different L

# input protein
pdb="$1"

# get length of protein
length=$(/home/cagostino/work/scripts/helper/findL.sh $pdb)

# get positions
positions=($(seq 1 $length))
# no mut to cysteine
aminos=(G A L M F W K Q E S P V I Y H R N D T)

# Array to store job IDs
job_ids=()

# init csv file
echo "pdb,mut_nrg,wt,pos,amino,wt_nrg,ratio" > output.csv

# run mutate
for i in "${positions[@]}"
do
    for j in "${aminos[@]}"
    do
        while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
        do
            sleep 1
        done
        job_id=$(/wistar/kulp/software/slurmq --sbatch "python /home/cagostino/work/scripts/rosetta/NNK/singlebody/singlebody_mutate.py --pdb $pdb --mut ${i}${j}" | awk '/Submitted batch job/ {print $4}')
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

echo "done"