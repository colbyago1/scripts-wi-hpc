#!/bin/bash
#SBATCH --job-name=colab
#SBATCH -c 4 #try 20
#SBATCH --mem 40GB #100
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclude=node050,node051
#SBATCH --time=2-03:59:59

# colabfold_batch . . --num-recycle 3 --num-models 3 --model-order 3,4,5
colabfold_batch . . --amber --num-relax 1 --use-gpu-relax