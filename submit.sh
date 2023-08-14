#!/bin/bash

n=100

for ((i=11; i<=$n; i++))
do
	# Using printf to pad the number with leading zeros
   	 dir_name=$(printf "run%03d" $i)
    
   	 # Create the directory
    	mkdir "$dir_name"
	
	cd $dir_name
	cp ../slurm.sh .
	cp ../flag_local_docking .
	sbatch slurm.sh
	sleep 1
	cd ..
done
