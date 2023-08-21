#!/bin/bash
#
#SBATCH --job-name=NNK               # create a short name for your job
#SBATCH --nodes=1                       # node count
#SBATCH --ntasks=1                      # total number of tasks across all nodes
#SBATCH --cpus-per-task=1               # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem=3GB                       # total memory allocated for all tasks
#SBATCH --time=01:00:00                 # total run time limit (HH:MM:SS)

source ~/.bashrc
micromamba activate pymol
python align.py $1 $4
micromamba activate PyRosetta.notebooks
python multibody_bind.py $1 $2 $3
