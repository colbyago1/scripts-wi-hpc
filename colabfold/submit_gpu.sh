#!/bin/bash
#SBATCH --job-name=colab2
#SBATCH -c 5 #try 20
#SBATCH --mem 100GB #350
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclude=node050,node051
#SBATCH --time=10-03:59:59

# colabfold_batch $1 "./${1::-4}" --num-models 3 --model-order 3,4,5 --num-recycle 1
# colabfold_batch $1 "./${1::-4}" --num-models 1 --model-order 3 --num-recycle 1
colabfold_batch . . --msa-mode single_sequence
# colabfold_batch $1 .
# colabfold_batch --model-type alphafold2_multimer_v3 $1 "./${1::-3}"

# colabfold_batch --msa-mode single_sequence $1 monomer_fa_gpu 


# colabfold_batch --msa-mode single_sequence --model-type alphafold2_multimer_v3 $1 multimer_fa_gpu