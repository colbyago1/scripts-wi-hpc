#!/bin/sh

partners="A_B"
wt_pdb=("815-1-18_GL_HC_dock_run083_0007_0001.pdb")

# WT
python bind_wt.py "$wt_pdb" "$partners"
read wt_unbound wt_nrg < "wt"

# init output.csv
echo "pdb,unbound nrg,ratio" > output.csv

for p in seq*.pdb
do
    while [ $(squeue -u cagostino -t running,pending | wc -l) -gt 250 ]
    do
        sleep 1
    done
    sbatch run.sh $p $partners $wt_nrg $wt_pdb
done

echo "done"

