#!/bin/bash

for i in `ls -d dir_v3g_topo01/run{001,002,003,004,005,006,007,008,009,010}`; do
    echo $i;
    cd $i;

    sbatch $HOME/work/scripts/rfDiffusion/new/homooligomer/homooligomer.sh;

    cd ../../;

done
