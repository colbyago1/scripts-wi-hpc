#!/bin/bash

# path="*/dir_v3g_topo0*/run*/pmpnn_seqs/seqs/a3m[23]"
# path2="traditional_mini/dir_v3g_topo01/run*/pmpnn_seqs/seqs/a3m2/dir*"
# path="refinement/untraditional_canonical_seq_sampling/*/pmpnn_seqs/seqs/a3m"
path="/home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/refinement/CC/*prot_topo*/a3m"

# Array to store job IDs
job_ids=()

for d in $path; do
    cd $d
    echo $d
    # job_id=$(/wistar/kulp/software/slurmq --sbatch "$HOME/work/scripts/colabfold/extract_metrics/extract_metrics.sh; $HOME/work/scripts/colabfold/extract_metrics/CF_rmsd.sh"; $HOME/work/scripts/colabfold/extract_metrics/CF_rmsd_bb.sh" | awk '/Submitted batch job/ {print $4}')
    job_id=$(/wistar/kulp/software/slurmq --sbatch "$HOME/work/scripts/colabfold/extract_metrics/CF_rmsd.sh" | awk '/Submitted batch job/ {print $4}')
    job_ids+=("$job_id")
    cd -
done

# for d in $path2; do
#     cd $d
#     echo $d
#     job_id=$(/wistar/kulp/software/slurmq --sbatch "$HOME/work/scripts/colabfold/extract_metrics_HTS/extract_metrics_HTS.sh; $HOME/work/scripts/colabfold/extract_metrics_HTS/CF_rmsd_HTS.sh" | awk '/Submitted batch job/ {print $4}')
#     job_ids+=("$job_id")
#     cd -
# done

# wait
for job_id in "${job_ids[@]}"
do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
done

echo "description,pLDDT,pTM,ipTM,rmsd" > output.csv
cat ${path}/output_rmsd.csv >> output.csv
