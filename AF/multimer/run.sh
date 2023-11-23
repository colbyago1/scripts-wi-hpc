#!/bin/bash

for f in ./*fa
do
	# while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
    #     do
    #     	sleep 1
    #     done
	sbatch $HOME/work/scripts/AF/multimer/submit.sh "$f"
done
