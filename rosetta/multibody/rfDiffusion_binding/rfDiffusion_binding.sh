#!/bin/sh

# consider alignMolecules for alignment then Biopython to combine PDBs

partners="MN_A"

# init output.csv
echo "pdb,unbound_nrg,binding_nrg" > binding_output.csv

# Array to store job IDs
job_ids=()
    
for p in *complex_0001.pdb
do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 50 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    job_id=$(/wistar/kulp/software/slurmq --sbatch "python $HOME/work/scripts/rosetta/multibody/rfDiffusion_binding/multibody_bind.py $p $partners" | awk '/Submitted batch job/ {print $4}')
    job_ids+=("$job_id")
done

for job_id in "${job_ids[@]}"; do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
    rm "slurm-$job_id.out"
done

cat *_binding.csv >> binding_output.csv

echo "done"

