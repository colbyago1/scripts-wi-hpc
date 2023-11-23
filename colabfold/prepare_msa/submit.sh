#!/bin/bash

output_dir="$1"
for f in *monomer.fa; do
    $HOME/work/scripts/colabfold/prepare_msa/prepare_msa_A.sh $f;
    for i in $(seq 1 100); do
        $HOME/work/scripts/colabfold/prepare_msa/prepare_msa_B.sh $f $i;
    done;
done
# mv *seq*.a3m $output_dir