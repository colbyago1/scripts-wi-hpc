#!/bin/bash
#SBATCH --job-name=TM
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --time=200:00:00

job_ids=()

for p in rfDiffusion/run*/pmpnn_seqs/seqs/1D8*/ranked_1.pdb; do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 250 ]; do
            sleep 1
    done
    job_id=$(/wistar/kulp/software/slurmq --sbatch "~/work/software/TM-search1.0/TMsearch $p -dirc /home/cagostino/work/software/TM-search1.0/PDB/ /home/cagostino/work/software/TM-search1.0/representive_list -outfmt 1 > ${p::-4}.TMsearch_result" | awk '/Submitted batch job/ {print $4}')
done

for job_id in "${job_ids[@]}"; do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"; do
        sleep 1
    done
done

echo "PDB,TMscore" > chroma.TMsearch_result
for p in rfDiffusion/run*/pmpnn_seqs/seqs/1D8*/*.TMsearch_result; do
    TMscore=$(grep ${p::-16}.pdb $p | awk -F '=' '{ if ($5 > max) max = $5 } END { print max }')
    echo "$p,$TMscore" >> rfDiffusion.TMsearch_result
done