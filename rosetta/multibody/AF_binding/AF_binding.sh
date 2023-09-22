#!/bin/sh

# consider alignMolecules for alignment then Biopython to combine PDBs

partners="A_B"
wt_pdb="$1"

# WT
python $HOME/work/scripts/rosetta/multibody/bind_wt.py "$wt_pdb" "$partners"
read wt_unbound wt_nrg < "wt"

# init output.csv
echo "pdb,unbound nrg,ratio" > output.csv

# Array to store job IDs
job_ids=()
    
for p in seq*.pdb
do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 50 ]
    do
        sleep 1
    done
    sbatch $HOME/work/scripts/rosetta/multibody/run.sh $p $partners $wt_nrg $wt_pdb
done

echo "done"

