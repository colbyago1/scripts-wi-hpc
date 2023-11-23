#!/bin/bash
#SBATCH --job-name=ThermoMPNN
#SBATCH -c 5 #try 20
#SBATCH --mem 100GB #350
#SBATCH --partition=smq
#SBATCH --gres=gpu:1
#SBATCH --time=0-03:59:59

source ~/.bashrc
micromamba activate thermoMPNN
module load CUDA/11.7.0

python ~/work/software/ThermoMPNN/analysis/custom_inference.py --pdb $1 --model_path /home/cagostino/work/software/ThermoMPNN/models/thermoMPNN_default.pt