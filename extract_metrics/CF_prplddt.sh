#!/bin/bash

> output_prplddt.csv
while IFS=',' read -r description rest_of_line || [ -n "$description" ]; do
    new_line=
    # echo $description
    base="${description%%unrelaxed*}"
    base=${base::-1}
    base=$(basename "$base")
    base="${base%%_seq*}"
    positions=($(grep "$base.pdb" ../../../align.csv | awk -F',' '{print $2}'))
    # echo positions ${positions[@]}
    prplddt=()
    for p in "${positions[@]}"; do
        # echo p
        prplddt+=("$(awk -v posi="$p" '/^ATOM/ && $3 == "CA" && $6 == posi {print $11}' "$description")")
    done

    sum=0
    for p in "${prplddt[@]}"; do
        sum=$(echo "$sum + $p" | bc)
    done

    # Calculate the mean
    count=${#prplddt[@]}
    epitope_pLDDT=$(echo "scale=2; $sum / $count" | bc)

    # echo "${prplddt[@]}"
    # echo $epitope_pLDDT

    new_line="$description,$rest_of_line,$epitope_pLDDT"
    echo "$new_line" >> output_prplddt.csv
done < output_rmsd_bb.csv