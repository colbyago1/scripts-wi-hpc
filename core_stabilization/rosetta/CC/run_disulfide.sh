#!/bin/sh
#SBATCH --job-name=NNK               # create a short name for your job
#SBATCH --nodes=1                       # node count
#SBATCH --ntasks=1                      # total number of tasks across all nodes
#SBATCH --cpus-per-task=1               # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem=30GB                       # total memory allocated for all tasks

# mutate
# python /home/cagostino/work/scripts/core_stabilization/rosetta/CC/mutate.py --pdb $1 --posi $2 --positions $3

pdb=$1
i=$2
j=$3

/home/dwkulp/software/mslib/bin/findDisulf --pdb "$pdb" --disulfPdb /home/dwkulp/wistar/data/disulfides/full_pdb_190722/CYS_CYS.bin --speak findDisulfides --binaryDB --modelBest --positions A,$i A,$j > "${pdb:0:-4}.log"

