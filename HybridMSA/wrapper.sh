#!/bin/bash
#SBATCH --time=10-03:59:59
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

path="/home/cagostino/work/workspace/method_validation/hybridMSA/rfDiffusion/topo*/pmpnn_seqs/seqs"

# change for each MSA
output_dir="a3m_SARS-CoV-2-RBD_monomer"

for d in $path; do
    (
    cd $d;
    echo $d

    if [ ! -d $output_dir ]
    then
        mkdir -p $output_dir
    fi
    sbatch /home/cagostino/work/workspace/method_validation/hybridMSA/HybridMSA/prepare_msa/run_prepare_msa.sh $output_dir
    )
done
