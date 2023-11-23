#!/bin/bash
  
#SBATCH --job-name=ab_mut
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --mem=50G
#SBATCH --exclude=node032
#SBATCH --gres=gpu:1

#conda activate /home/dwkulp/software/miniconda3/envs/esmfold2
module load CUDA

export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm

esm-fold -i combined.fa -o structures




