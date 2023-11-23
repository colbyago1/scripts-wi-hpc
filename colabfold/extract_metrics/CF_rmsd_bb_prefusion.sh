#!/bin/bash

# echo "description,pLDDT,pTM,ipTM,rmsd" > output_rmsd.csv
> test.csv
while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=

    base=$(basename $description)
    name="${base%%-*}"
    dir=$(dirname $(dirname $(dirname $(dirname $description))))

    # if [[ $description == *intraprot* ]]; then
    if [[ $description == *sym*  ]]; then

        # fix
        path=$dir/$name-fix/$name-fix.pdb

        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path --pdb2 $description --sele1 name CA --sele2 name CA --noOutputPdb | awk '/RMSD/{print $2}')
    

        new_line="$description,$rest_of_line,$rmsd"
    # elif [[ $description == *interprot* ]]; then
    elif [[ $description == *canonical* ]]; then
        
        # aln
        path=$dir/$name-aln/$name-aln.pdb
        
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path --pdb2 $description --sele1 name CA --sele2 name CA --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
    
    
    elif [[ $description == *canonical* ]]; then
        
        # none
        path=$dir/$name/$name.pdb
        
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 $path --pdb2 $description --sele1 name CA --sele2 name CA --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
    
    
    else
        new_line="$description,$rest_of_line"
    fi
    echo "$new_line" >> test.csv
done < $1