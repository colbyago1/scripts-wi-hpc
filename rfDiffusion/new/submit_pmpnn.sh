#!/bin/bash

for i in `ls -d dir_v3g_topo{01,02}/run{001,002,003,004,005,006,007,008,009,010}`; do
    echo $i;
    cd $i;

    sbatch /home/dwkulp/projects/HIV/V3glycan_rfdiff/sbatch_pmpnn.txt

    cd ../../;

done
