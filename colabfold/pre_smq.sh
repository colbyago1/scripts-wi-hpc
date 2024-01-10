#!/bin/bash
#SBATCH --job-name=colab
#SBATCH -c 4 #try 20
#SBATCH --mem 40GB #100
#SBATCH --partition=smq
#SBATCH --gres=gpu:1
#SBATCH --exclude=node050,node051
#SBATCH --time=0-03:59:59

colabfold_batch . . --num-recycle 3 --num-models 3 --model-order 3,4,5
# colabfold_batch $1 .
# colabfold_batch --model-type alphafold2_multimer_v3 $1 "./${1::-3}"

# colabfold_batch --msa-mode single_sequence $1 monomer_fa_gpu 


# colabfold_batch --msa-mode single_sequence --model-type alphafold2_multimer_v3 $1 multimer_fa_gpu