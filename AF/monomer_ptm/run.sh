#!/bin/bash

for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
        do
        	sleep 1
        done
	sbatch submit.sh "$f"
done
