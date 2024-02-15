#!/bin/bash

#conda activate /home/dwkulp/software/miniconda3/envs/esmfold2
#module load CUDA

#export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm
for struct in *.fasta
do
	cd "${struct::-6}"

	cat *.fa > combined.fa

	cp ../submit_batch.sh .

	while [ $(squeue -u sgarfinkle -t pending | wc -l) -gt 10 ]
        do
        	sleep 1
        done
	sbatch submit_batch.sh
	
	cd ..
done	
