#!/bin/sh
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --time=27-03:59:59

for d in /home/cagostino/work/workspace/gp120-gp41_interface/35O22/*/rfDiffusion/topo*/pmpnn_seqs/seqs/a3m; do
    # Create 50 subdirectories
    mkdir -p "${d}/run"{01..50}

    files=$(find "$d" -maxdepth 1 -type f)

    for file in $files; do
        dest="$d/run$(printf '%02d' $(( RANDOM % 50 + 1 )))"
        mv "$file" "$dest"
    done

    while [ $(squeue -u cagostino -t pending | wc -l) -gt 51 ]; do
        sleep 1
    done

    for s in $d/run*; do
        cd $s

        if [ $(squeue -u cagostino | awk '$2=="gpu" {print $2}' | wc -l) -lt 24 ]; then
            sbatch ~/work/scripts/colabfold/pre_gpu.sh
        else
            sbatch ~/work/scripts/colabfold/pre_smq.sh
        fi

        cd -
    done

done