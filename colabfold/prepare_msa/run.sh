#!/bin/bash

path="*mini*/pmpnn_seqs/seqs"
# path="canonical_mini_sym/dir_v3g_topo01/run573/pmpnn_seqs/seqs"

output_dir="a3m"

for d in $path; do
    (
    cd $d;
    echo $d

    if [ ! -d $output_dir ]
    then
        mkdir -p $output_dir
    fi
    sbatch $HOME/work/scripts/colabfold/prepare_msa/submit.sh $output_dir
    )
done
