#!/bin/bash
#SBATCH --job-name=AF
#SBATCH -c 40 #try 20
#SBATCH --mem 100GB #350 
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
module load AlphaFold
export ALPHAFOLD_HHBLITS_N_CPU=14
alphafold --fasta_paths="$1" --max_template_date=2020-05-14 --data_dir=/resources/AlphaFoldDB --output_dir=/wistar/kulp/users/cagostino/workspace/eOD/815_OD-1-18_GL_HC/AF2 --model_preset=monomer

