#!/bin/bash

for i in `seq 1 10`; do
    dir=`printf "run%02d" $i`;
    mkdir -p $dir;
    cd $dir;
	sbatch ../scaffold.py;
	cd ..;
done 
