#!/bin/bash

for i in `ls -d dir_v3g_topo01/run*`; do
    echo $i;
    cd $i;

    sbatch $HOME/work/scripts/rfDiffusion/new/homooligomer_sym/homooligomer.sh;

    cd ../../;

done
