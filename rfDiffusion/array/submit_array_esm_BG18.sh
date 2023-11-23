#!/bin/bash
#SBATCH --job-name=e_BG18
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=50Gb
#SBATCH --array=1-50%20
#SBATCH --output=bg18_esm_%A_%a.out
#SBATCH --error=bg18_esm_%A_%a.err

i=${SLURM_ARRAY_TASK_ID}

dir2=`printf "BG18mat_run%03d/BG18mat_run%03d/pmpnn_seqs/seqs" $i $i`;
cd $dir2;

# Make a master sequence file 
for j in `ls *.fa | grep -v master`; do
    /home/dwkulp/projects/design/ProteinMPNN/getSeqsPMPNN.pl $j;
done > tmp;
mv tmp master.fa;

#echo "Split sequence file"
# Split into close to 3 files so that we have 3 jobs per directory
#wc=`wc -l master.fa | awk '{print $1}'`;lines=$((wc/3)); extra=$((wc/3%2));lines2=$((lines+extra));echo $lines2;split -l $lines2 master.fa
    
#for j in `ls x??`; do
out=`printf "out_esm_%d" $i`;
log=`printf "log_esm_%d" $i`;
echo $out;

fasta="master.fa"
dir="out_esm"

source /home/dwkulp/.bashrc
conda activate /home/dwkulp/software/miniconda3/envs/esmfold2
#module load CUDA
export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-\
packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm
#esm-fold -i foo.fa -o foo5.pdb --cpu-only
#esm-fold -i foo.fa -o foo6.pdb
esm-fold -i $fasta -o $dir > $log

