#!/bin/bash

for f in ./*a3m
do
	# while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
    #     do
    #     	sleep 1
    #     done
	sbatch $HOME/work/scripts/colabfold/submit_gpu.sh "$f"
done
