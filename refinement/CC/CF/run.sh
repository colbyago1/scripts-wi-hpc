#!/bin/bash

job_ids=()

for p in *.pdb; do
    mkdir ${p::-4}
    cp $p ${p::-4}
    cp ${p::-4}.a3m ${p::-4}
    cd ${p::-4}
    job_id=$(sbatch $HOME/work/scripts/refinement/CC/CF/CC.sh $p | awk '{print $4}');
    job_ids+=("$job_id")
    cd ..
done

echo "wait"

# wait
for job_id in "${job_ids[@]}"
do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
done

for p in *.pdb; do
    cd ${p::-4}
    mkdir a3m
    for f in *C*C*.a3m; do mv $f a3m/$f; done
    cd a3m
    sbatch $HOME/work/scripts/colabfold/pre_gpu.sh
    cd ../..
done