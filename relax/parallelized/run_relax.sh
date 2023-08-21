#!/bin/bash

for p in *pdb
do
    while [ $(squeue -u cagostino -t running,pending | wc -l) -gt 250 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    sbatch /home/cagostino/work/scripts/relax/parallelized/run.sh $p
done

