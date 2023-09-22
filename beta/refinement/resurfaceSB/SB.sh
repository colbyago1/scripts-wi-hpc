#!/bin/sh

# input protein
pdb="$1"

# Run findDisulfs
/home/dwkulp/software/mslib.git/mslib/bin/resurfaceSaltBridges --pdb $pdb --fasta

# create fastas
source $HOME/.bashrc
bio
wt=$(python /home/cagostino/work/scripts/helper/pdb2seq.py $pdb)
length=${#wt}

for seq in $(awk 'NR % 2 == 0' RSB_${pdb::-4}.fasta);
do
    for ((i=0; i<length; i++)); do
    char_wt="${wt:i:1}"
    char_seq="${seq:i:1}"
    muts=()
    if [ "$char1" != "$char2" ]
    then
        muts+=("$char2$((i+1))")
    fi
    done
    
    # Initialize the 'name' variable with ${pdb::-4}
    name="${pdb::-4}"

    # Loop through the array and append elements separated by underscores
    for element in "${my_array[@]}"; do
    name="${name}_${element}"
    done

    echo ">$name" > "$name.fa"
    echo "$seq" >> "$name.fa"
done

micromamba activate /home/dwkulp/software/miniconda3/envs/esmfold2
module load CUDA
export PYTHONPATH=/home/dwkulp/software/esm/esm/build/lib:/home/dwkulp/software/esm/esm/build/lib/esm:/home/dwkulp/software/miniconda3/envs/esmfold2/lib/python3.9/site-packages/:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm:/home/dwkulp/software/esm/esm

# NNK
for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
        do
        	sleep 1
        done
	sbatch ~/work/scripts/core_stabilization/rosetta/SB/submit.sh "$f"
done