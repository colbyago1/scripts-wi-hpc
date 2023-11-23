#!/bin/bash

for i in `seq 1 24`; do
    dir=`printf "dir_v3g_topo%02d" $i`;
    mkdir -p $dir;
    cd $dir;
    for j in `seq 1 10`; do
    	dir2=`printf "run%03d" $j`;
	mkdir -p $dir2;
	cd $dir2;
	sbatch --export=ALL,topo="$i" ../../sbatch_rfdiff_topoX.txt;
	cd ..;
    done;
    cd .. ;
done 
