#!/bin/bash

# echo "description,pLDDT,pTM,ipTM,rmsd" > output_rmsd.csv
> output_rmsd.csv
while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=
    base=$(basename $description)
    name="${base%%-*}"
    dir=$(dirname $(dirname $(dirname $(dirname $description))))
    path=$dir/$name/$name.pdb
    if [[ $description == *intraprot* ]]; then
    # if [[ $description == *untraditional* ]]; then
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path --pdb2 $description --sele1 name CA --sele2 name CA | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
    elif [[ $description == *interprot* ]]; then
    # elif [[ $description == *traditional* || $description == *canonical* ]]; then
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path --pdb2 $description --sele1 name CA --sele2 name CA --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
    else
        new_line="$description,$rest_of_line"
    fi
    echo "$new_line" >> output_rmsd.csv
done < output.csv