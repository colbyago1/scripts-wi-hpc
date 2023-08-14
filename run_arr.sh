#!/bin/bash
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --ntasks=1
#SBATCH --array=1-114%15   # This means there are same kind of 114 jobs and each time 15 of them are running until all 114 are done
#SBATCH --output=array_%A_%a.out
#SBATCH --error=array_%A_%a.err
#SBATCH --mem-per-cpu=3G

#above settings allocate 10 cpus per task and each cpu gets 3GB

module load BWA/0.7.17-GCCcore-11.2.0
module load SAMtools/1.15.1-GCC-11.2.0
module load Java/11.0.2
module load picard/2.26.10-Java-15
module load Bowtie/1.3.1-GCC-11.2.0
module load Bowtie2/2.4.4-GCC-11.2.0


####This is how you read input data
r1=`sed -n "$SLURM_ARRAY_TASK_ID"p sample.txt |  awk '{print $1}'`
r2=`sed -n "$SLURM_ARRAY_TASK_ID"p sample.txt |  awk '{print $2}'`
pth=`sed -n "$SLURM_ARRAY_TASK_ID"p sample.txt |  awk '{print $3}'` 
tp=`sed -n "$SLURM_ARRAY_TASK_ID"p sample.txt |  awk '{print $4}'`

##This is how you use input data
mkdir "$pth"tmmp 
