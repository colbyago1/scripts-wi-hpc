#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=50Gb

source /home/dwkulp/.bashrc
conda activate /home/dwkulp/software/miniconda3/envs/esmfold2
module load CUDA
export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-\
packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm

esm-fold -i $fasta -o $dir > $log
