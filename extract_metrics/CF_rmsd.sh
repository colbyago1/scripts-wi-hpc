#!/bin/bash

> output_rmsd.csv
while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=
    base="${description%%unrelaxed*}"
    base=${base::-1}
    base=$(basename "$base")
    base="${base%%_seq*}"
    positions="$(grep "$base.pdb" ../../../align.csv | awk -F',' '{print $2}')"
    # MPNNscore="$(grep "$base.pdb" ../../../MPNN.csv | awk -F',' '{print $2}')"
    sele_string=$(echo $positions | tr ' ' '+')
    rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/EBV/preliminary_data/1KG0/rfDiffusion/1KG0_renumb.pdb --pdb2 $description --sele1 name CA --sele2 name CA and resi $sele_string --regex ".*(CNTREYTFSYK).*" --regex ".*(VTRNLNAIESL).*" --regex ".*(SQRS).*" --noOutputPdb | awk '/RMSD/{print $2}')
    # new_line="$description,$rest_of_line,$rmsd,$MPNNscore"
    new_line="$description,$rest_of_line,$rmsd"
    echo "$new_line" >> output_rmsd.csv
done < CF_output.csv
