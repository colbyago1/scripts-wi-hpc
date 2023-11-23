#!/bin/bash

if [[ $(basename $PWD) == monomer ]]; then
    cd output_files
    echo "description,pLDDT,rmsd" > AF_rmsd.csv
elif [[ $(basename $PWD) == multimer ]]; then
    cd output_files
    echo "description,pLDDT,iptm+ptm,rmsd,rmsd_trimer" > AF_rmsd.csv
else
    exit 1
fi

tail -n +2 AF.csv | while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=
    if [[ $description == untraditional* ]]; then
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/untraditional_mini/untraditional_ref.pdb --pdb2 $description --sele1 name CA and chain A --sele2 name CA and chain A --regex ".*(NLWVTVYYGVPVWK).*" --regex ".*(KIEPLGVAPTRCKRR).*" --regex ".*(LGFLGAAGSTMGAASMTLTVQARNLLS).*" --regex ".*(GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD).*" --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
        if [[ $(basename $(dirname $PWD)) == multimer ]]; then
            rmsd_trimer=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/untraditional_mini/untraditional_ref.pdb --pdb2 $description --sele1 name CA --sele2 name CA --regex ".*(NLWVTVYYGVPVWK).*" --regex ".*(KIEPLGVAPTRCKRR).*" --regex ".*(LGFLGAAGSTMGAASMTLTVQARNLLS).*" --regex ".*(GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD).*" --noOutputPdb | awk '/RMSD/{print $2}')
            new_line="$description,$rest_of_line,$rmsd,$rmsd_trimer"
        fi
    elif [[ $description == traditional* ]]; then
        rmsd=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/traditional_mini/traditional_ref.pdb --pdb2 $description --sele1 name CA and chain A --sele2 name CA and chain A --regex ".*(NLWVTVYYGVPVWK).*" --regex ".*(KIEPLGVAPTRCKRR).*" --regex ".*(LGFLGAAGSTMGAASMTLTVQARNLLS).*" --regex ".*(GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD).*" --noOutputPdb | awk '/RMSD/{print $2}')
        new_line="$description,$rest_of_line,$rmsd"
        if [[ $(basename $(dirname $PWD)) == multimer ]]; then
            rmsd_trimer=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules  --pdb1 /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/traditional_mini/traditional_ref.pdb --pdb2 $description --sele1 name CA --sele2 name CA --regex ".*(NLWVTVYYGVPVWK).*" --regex ".*(KIEPLGVAPTRCKRR).*" --regex ".*(LGFLGAAGSTMGAASMTLTVQARNLLS).*" --regex ".*(GIKQLQARVLAVEHYLRDQQLLGIWGCSGKLICCTNVPWNSSWSNRNLSEIWDNMTWLQWDKEISNYTQIIYGLLEESQNQQEKNEQDLLALD).*" --noOutputPdb | awk '/RMSD/{print $2}')
            new_line="$description,$rest_of_line,$rmsd,$rmsd_trimer"
        fi
    else
        new_line="$description,$rest_of_line"
    fi
    echo "$new_line" >> AF_rmsd.csv
done

cd ..