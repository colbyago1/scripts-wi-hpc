#!/bin/bash

> output_rmsd_bb.csv
while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=
    base="${description%%unrelaxed*}"
    base=${base::-1}
    base=$(basename "$base")
    base="${base%%_seq*}"
    path=$(dirname $(dirname $(dirname $PWD)))/${base}/${base}.pdb
    rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path --pdb2 $description --sele1 chain A and name CA --sele2 chain A and name CA --noOutputPdb | awk '/RMSD/{print $2}')
    new_line="$description,$rest_of_line,$rmsd"
    echo "$new_line" >> output_rmsd_bb.csv
done < output_rmsd.csv