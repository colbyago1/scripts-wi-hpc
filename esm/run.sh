#!/bin/bash

for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
        do
        	sleep 1
        done
	sbatch $HOME/work/scripts/esm/submit_gpu.sh "$f"
done
