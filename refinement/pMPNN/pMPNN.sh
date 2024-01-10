#!/bin/bash

# run pMPNN with --unconditional_probs_only, output highest probabilities

pdb="$1"

# # run pMPNN
# source ~/.bashrc
# micromamba activate SE3nv
# job_id=$(sbatch /home/cagostino/work/scripts/refinement/pMPNN/submit.sh | awk '{print $4}')

# while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
# do
#     sleep 1
# done

# micromamba activate bio
seq=$(cat $pdb | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')

echo $seq

python /home/cagostino/work/scripts/refinement/pMPNN/pMPNN.py "$pdb" "$seq"
