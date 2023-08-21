#!/bin/sh
#SBATCH --job-name=NNK               # create a short name for your job
#SBATCH --nodes=1                       # node count
#SBATCH --ntasks=1                      # total number of tasks across all nodes
#SBATCH --cpus-per-task=1               # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem=3GB                       # total memory allocated for all tasks

# mutate
python /home/cagostino/work/scripts/core_stabilization/rosetta/SASA/mutate.py --pdb $1 --posi $2 --amino $3

