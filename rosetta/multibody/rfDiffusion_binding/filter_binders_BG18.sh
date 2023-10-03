#!/bin/bash

# inFile="$1"
# backbone_input="/wistar/kulp/users/dwkulp/projects/AbsBinders/V3_bnAbs_PGT121_BG18/BG18_mature/BG18_mature_clean.pdb"
# # partners for SASA and rosetta binding (Ab_binder)
# partners="H_A"

# > alignMolecules_Ab.log
# > alignMolecules_binder.log

# tail -n +2 "$inFile" | while IFS=',' read -r backbone_output design trash rmsd lddt || [ -n "$backbone_output" ]; do
#     # alignMolecules (binder)
#     /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $backbone_output --pdb2 $design --sele1 "chain A and name CA" --sele2 "name CA" >> alignMolecules_binder.log
    
#     # get base name
#     base_name_binder=$(basename $design)

#     # get aligned name
#     aligned_name_binder="${base_name_binder%.*}-aligned.pdb"

#     # get design name
#     runname=$(dirname $backbone_output)
#     runname=$(basename $runname)
#     designname=$(basename $design)

#     name="${runname}_${designname::-4}"
#     name_binder="${name}_binder.pdb"

#     # rename aligned file
#     mv $aligned_name_binder $name_binder
    
#     # Extract chain A from alignedname and save it to a temporary file
#     grep "^ATOM" $name_binder | awk '$5 == "A" {print $0}' >> "${name%.*}_complex.pdb"

#     # alignMolecules (Ab)
#     /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $backbone_output --pdb2 $backbone_input --sele1 "chain B and name CA" --sele2 "name CA" >> alignMolecules_Ab.log

#     # get base name
#     base_name_Ab=$(basename $backbone_input)


#     # get aligned name
#     aligned_name_Ab="${base_name_Ab%.*}-aligned.pdb"

#     # get design name
#     name_Ab="${name}_Ab.pdb"

#     # rename aligned file
#     mv $aligned_name_Ab $name_Ab

#     # Extract chain B from backbone and save it to another temporary file
#     grep "^ATOM" $name_Ab | awk '$5 == "H" {print $0}' >> "${name%.*}_complex.pdb"

# done

# # Array to store job IDs
# job_ids=()

# for pdb in *_complex.pdb; do
#     while [ $(squeue -u cagostino -t pending | wc -l) -gt 250 ]
#     do
#         sleep 1
#     done
#     # Submit the job and capture the job ID
#     job_id=$(/wistar/kulp/software/slurmq --sbatch "/home/dwkulp/software/Rosetta/main/source/bin/relax.linuxgccrelease -in::file::s "$pdb" -in:file:fullatom -relax:quick -relax:constrain_relax_to_start_coords -relax:sc_cst_maxdist 0.5" | awk '/Submitted batch job/ {print $4}')
#     job_ids+=("$job_id")
# done

# for job_id in "${job_ids[@]}"; do
#     while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
#     do
#         sleep 1
#     done
#     rm "slurm-$job_id.out"
# done

# echo "done"

# rdDiffusion binding

# # init output.csv
# echo "pdb,unbound_nrg,binding_nrg" > binding_output.csv
# init output.csv
echo "pdb,SASA_binder,SASA_Ab,SASA_total,SASA_diff" > SASA_output.csv

# Array to store job IDs
job_ids=()
    
for p in *complex_0001.pdb
do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 250 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    # job_id=$(/wistar/kulp/software/slurmq --sbatch "python $HOME/work/scripts/rosetta/multibody/rfDiffusion_binding/multibody_bind.py $p $partners" | awk '/Submitted batch job/ {print $4}')
    # job_ids+=("$job_id")
    job_id=$(/wistar/kulp/software/slurmq --sbatch "$HOME/work/scripts/rosetta/multibody/rfDiffusion_binding/SASA.sh $p $partners" | awk '/Submitted batch job/ {print $4}')
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
cat *_SASA.csv >> SASA_output.csv

echo "done"