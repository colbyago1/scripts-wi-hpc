#!/bin/bash

# inFile="20_sep_candidates_better.csv"
# backbone_input="/wistar/kulp/users/dwkulp/projects/AbsBinders/APEX_bnAbs_CH01/hotspot1_fullabs/CH01_iGL.pdb"

# > alignMolecules_Ab.log
# > alignMolecules_binder.log

# tail -n +2 "$inFile" | while IFS=',' read -r backbone_output design rmsd lddt blank runname designname || [ -n "$backbone_output" ]; do
#     # alignMolecules (binder)
#     /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $backbone_output --pdb2 $design --sele1 "chain A and name CA" --sele2 "name CA" >> alignMolecules_binder.log
    
#     # get base name
#     base_name_binder=$(basename $design)

#     # get aligned name
#     aligned_name_binder="${base_name_binder%.*}-aligned.pdb"

#     # get design name
#     name="${runname}_${designname::-5}"
#     name_binder="${name}_binder.pdb"
#     # name_binder=$(echo "$name_binder" | tr -d '\r')

#     # rename aligned file
#     mv $aligned_name_binder $name_binder
    
#     # Extract chain A from alignedname and save it to a temporary file
#     grep "^ATOM" $name_binder | awk '$5 == "A" {print $0}' >> "${name%.*}_complex.pdb"

#     # alignMolecules (Ab)
#     /home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $backbone_output --pdb2 $backbone_input --sele1 "chain B and name CA" --sele2 "name CA and resi 1-131" >> alignMolecules_Ab.log

#     # get base name
#     base_name_Ab=$(basename $backbone_input)

#     # get aligned name
#     aligned_name_Ab="${base_name_Ab%.*}-aligned.pdb"

#     # get design name
#     name_Ab="${name}_Ab.pdb"
#     # name_Ab=$(echo "$name_Ab" | tr -d '\r')

#     # rename aligned file
#     mv $aligned_name_Ab $name_Ab

#     # Extract chain B from backbone and save it to another temporary file
#     grep "^ATOM" $name_Ab | awk '$5 == "M" {print $0}' >> "${name%.*}_complex.pdb"

#     # Extract chain B from backbone and save it to another temporary file
#     grep "^ATOM" $name_Ab | awk '$5 == "N" {print $0}' >> "${name%.*}_complex.pdb"
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
# /wistar/kulp/software/slurmq --sbatch "$HOME/work/scripts/rosetta/multibody/rfDiffusion_binding/rfDiffusion_binding.sh"

# Array to store job IDs
job_ids=()

# init output.csv
echo "pdb,SASA_binder,SASA_Ab,SASA_total,SASA_diff" > SASA_output.csv

# SASA
for p in *complex_0001.pdb
do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 250 ]
    do
        sleep 1
    done
    # Submit the job and capture the job ID
    job_id=$(/wistar/kulp/software/slurmq --sbatch "$HOME/work/scripts/rosetta/multibody/rfDiffusion_binding/SASA.sh $p" | awk '/Submitted batch job/ {print $4}')
    job_ids+=("$job_id")
done

cat *_SASA.csv >> SASA_output.csv

echo "done"