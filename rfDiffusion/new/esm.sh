#!/bin/bash

### TEST ###

# *traditional_mini*/dir*/run*/pmpnn_seqs/seqs/*-monomer.fa

# test 100 traditional, untraditional, traditional_sym, untraditional_sym

# monomer and multimer

# try 21-fix-monomer.fa or higher?

# 

### RUN ###

#SBATCH --job-name=esm
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=50Gb
#SBATCH --array=1-10%5
#SBATCH --output=esm_%A_%a.out
#SBATCH --error=esm_%A_%a.err

i=${SLURM_ARRAY_TASK_ID}

dir2=`printf "traditional_mini/dir_v3g_topo01/run%03d/pmpnn_seqs/seqs/" $i`;
# dir2=`printf "traditional_mini/dir_v3g_topo02/run%03d/pmpnn_seqs/seqs/" $i`;
# dir2=`printf "untraditional_mini/dir_v3g_topo01/run%03d/pmpnn_seqs/seqs/" $i`;
# dir2=`printf "untraditional_mini/dir_v3g_topo02/run%03d/pmpnn_seqs/seqs/" $i`;

cd $dir2;

cat *-monomer.fa > master.fa

esm-fold -i master.fa -o structures