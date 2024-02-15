#!/bin/bash
#SBATCH --job-name=AF
#SBATCH -c 20 #try 20
#SBATCH --mem 100GB #350 
#SBATCH --partition=smq
#SBATCH --gres=gpu:1
#SBATCH --time=0-3:59:59
module load AlphaFold
export ALPHAFOLD_HHBLITS_N_CPU=14
alphafold --fasta_paths="$1" --max_template_date=2020-05-14 --data_dir=/resources/AlphaFoldDB --output_dir=. --model_preset=monomer # --use_precomputed_msas=true
