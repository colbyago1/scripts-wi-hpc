#!/bin/bash
#SBATCH --time=10-03:59:59
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

output_dir="$1"
rm error.log
for f in *[0-9].fasta; do
	/home/cagostino/work/workspace/method_validation/hybridMSA/HybridMSA/prepare_msa/prepare_msa_A.sh $f;
    /home/cagostino/work/workspace/method_validation/hybridMSA/HybridMSA/prepare_msa/prepare_msa_B.sh $f 1;
done
mv *seq*.a3m $output_dir
