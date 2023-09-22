#!/bin/sh

# input protein
pdb="$1"

# Run findDisulfs
/home/dwkulp/software/mslib/bin/findDisulf --pdb $pdb --disulfPdb /home/dwkulp/wistar/data/disulfides/full_pdb_190722/CYS_CYS.bin --speak findDisulfides --binaryDB --modelBest --fasta > findDisulf.log

source $HOME/.bashrc
bio

# create fastas
for p in *bestDisulf*
do
    numbers=$(echo "$p" | grep -oE '[0-9]+_[0-9]+' | tail -n 1)
    IFS='_' read -r num1 num2 <<< "$numbers"
    seq=$(python /home/cagostino/work/scripts/helper/pdb2seq.py $p)
    echo ">${pdb::-4}_C$num1_C$num2" > "${pdb::-4}_C$num1_C$num2.fa"
    echo "$seq" >> "${pdb::-4}_C$num1_C$num2.fa"
done

micromamba activate /home/dwkulp/software/miniconda3/envs/esmfold2
module load CUDA
export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm

# NNK
for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
        do
        	sleep 1
        done
	sbatch ~/work/scripts/core_stabilization/rosetta/CC/submit_gpu.sh "$f"
done