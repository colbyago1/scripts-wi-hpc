#!/bin/bash

# echo "description,pLDDT,pTM,ipTM,rmsd" > output_rmsd.csv
> output_rmsd.csv
while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=
    if [[ $description == *intraprot* ]]; then
    # if [[ $description == *untraditional* ]]; then
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/untraditional_mini/untraditional_ref.pdb --pdb2 $description --sele1 name CA --sele2 name CA --regex ".*(NLWVTVYYGVPVWK).*" --regex ".*(KIEPLGVAPTRCKRR).*" --regex ".*(LGFLGAAGSTMGAASMTLTVQARNLLS).*" --regex ".*(GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD).*" --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
    elif [[ $description == *interprot* ]]; then
    # elif [[ $description == *traditional* || $description == *canonical* ]]; then
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/traditional_mini/traditional_ref.pdb --pdb2 $description --sele1 name CA --sele2 name CA --regex ".*(NLWVTVYYGVPVWK).*" --regex ".*(KIEPLGVAPTRCKRR).*" --regex ".*(LGFLGAAGSTMGAASMTLTVQARNLLS).*" --regex ".*(GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD).*" --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
    else
        new_line="$description,$rest_of_line"
    fi
    echo "$new_line" >> output_rmsd.csv
done < output.csv