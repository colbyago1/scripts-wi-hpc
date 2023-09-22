#!/bin/bash

# run pMPNN with --unconditional_probs_only, output highest probabilities

pdb="$1"

# run pMPNN
source ~/.bashrc
micromamba activate SE3nv
job_id=$(sbatch /home/cagostino/work/scripts/core_stabilization/pMPNN/submit.sh | awk '{print $4}')

while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
do
    sleep 1
done

micromamba activate bio
seq=$(python /home/cagostino/work/scripts/core_stabilization/pMPNN/pdb2seq.py "inputs/$pdb")

python /home/cagostino/work/scripts/core_stabilization/pMPNN/pMPNN_NNK.py "$pdb" "$seq"