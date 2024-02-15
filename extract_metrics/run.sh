#!/bin/bash

path="/home/cagostino/work/workspace/EBV/preliminary_data/1KG0/rfDiffusion/topo*/pmpnn_seqs/seqs/run*"

# Array to store job IDs
job_ids=()

for d in $path; do
    while [ $(squeue -u cagostino -t running,pending | wc -l) -gt 500 ]; do
        sleep 1
    done
    cd $d
    echo $d
    job_id=$(/wistar/kulp/software/slurmq --sbatch "/home/cagostino/work/workspace/EBV/preliminary_data/1KG0/extract_metrics/CF_extract_metrics.sh; /home/cagostino/work/workspace/EBV/preliminary_data/1KG0/extract_metrics/CF_rmsd.sh; /home/cagostino/work/workspace/EBV/preliminary_data/1KG0/extract_metrics/CF_rmsd_bb.sh; /home/cagostino/work/workspace/EBV/preliminary_data/1KG0/extract_metrics/CF_prplddt.sh" | awk '/Submitted batch job/ {print $4}')
    job_ids+=("$job_id")
    cd -
done


# wait
for job_id in "${job_ids[@]}"
do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
done

echo "description,pLDDT,rmsd_epitope,rmsd_bb,prpLDDT" > output_metrics.csv
cat ${path}/output_prplddt.csv >> output_metrics.csv
