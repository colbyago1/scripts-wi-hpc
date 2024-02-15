#!/bin/bash

for i in `seq 1 1`; do
    dir=`printf "dir_v2a_20aa_topo%02d" $i`;
    mkdir -p $dir;
    cd $dir;
    for j in `seq 1 2`; do
    	dir2=`printf "run%03d" $j`;
	mkdir -p $dir2;
	cd $dir2;
	sbatch --export=ALL,topo="$i" ../../sbatch_rfdiff.sh;
	cd ..;
    done;
    cd .. ;
done 
