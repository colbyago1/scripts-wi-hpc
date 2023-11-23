#!/bin/bash

pdb=$1 #calibrate hydrophobes and SASA cutoff

# surface-exposed hydrophobe filter

# 3-letter codes
hydrophobes=("A" "F" "I") # do not include C

/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $pdb --writeNormSasa --sele chain A --reportByResidue | tail -n +14 | head -n -2 > ${pdb::-4}_SASA.csv

# array for surface-exposed residues
surface_resis=()

# get SASA from complex
while read -r line; do
    # if residue is surface-exposed
    resi=$(echo $line | awk -F',' '{print $5 + 1}')
    SASA=$(awk -v resi=$resi '$2 == resi {print $5}' ${pdb::-4}_SASA.csv)
    if (( $(echo "$SASA > 0.4" | bc -l) )) && [[ ! " ${surface_resis[@]} " =~ " $resi " ]]; then
        # surface-exposed hydrophobic residue
        surface_resis+=("$resi")
        # echo $SASA, $resi
    fi
done < ThermoMPNN_inference_${pdb::-4}.csv

echo surface resis
echo ${surface_resis[@]}

# Unpaired cysteine filter

# cysteines with ddG < 0
negC=($(awk -F',' '$7=="C" && $4 < 0 { print $5 + 1 }' "ThermoMPNN_inference_${pdb::-4}.csv"))
# echo "cysteines with ddG < 0"
# echo ${negC[@]}
# disulfides with numDisulfs > 3
# Command to extract data and filter unique values
disulfs=($(grep "DATA" "../CC/${pdb::-4}"/*out | awk '$6 > 3 {split($3, words3, ","); split($4, words4, ","); printf "%s,%s\n", words3[2], words4[2]}' | sort -u))

# Print unique values stored in the disulfs array
echo "${disulfs[@]}"

# echo "disulfides with numDisulfs > 3"
# echo ${disulfs[@]}

# get unique disulf

# array to store ddG, resiA, resiB of negC_disulfs
negC_disulfs=()

# iterate through disulfs
for f in ${disulfs[@]}; do
    # split resis
    read resiA resiB <<< $(echo "$f" | awk -F, '{print $1, $2}')
    # if both resis from disulf are in negC
    # if [[ "${negC[*]}" =~ "$resiA" && "${negC[*]}" =~ "$resiB" ]]; then
    bool_resiA=false
    bool_resiB=false
    # Loop through the elements of negC array
    for element in "${negC[@]}"; do
        # Check if the element is exactly equal to resiA
        if [ "$element" == "$resiA" ]; then
            bool_resiA=true
        fi

        # Check if the element is exactly equal to resiB
        if [ "$element" == "$resiB" ]; then
            bool_resiB=true
        fi
    done
    # sum ddGs
    negC_A=$(awk -F',' -v variable=$resiA '$7=="C" && $5 == variable-1 { print $4 }' "ThermoMPNN_inference_${pdb::-4}.csv")
    negC_B=$(awk -F',' -v variable=$resiB '$7=="C" && $5 == variable-1 { print $4 }' "ThermoMPNN_inference_${pdb::-4}.csv")
    sum=$(echo "$negC_A + $negC_B" | bc -l)
    formatted_sum=$(printf "%.9f" "$sum")
    if [[ "$bool_resiA" == true && "$bool_resiB" =~ true &&  ! ${negC_disulfs[@]} =~ "$formatted_sum,$resiA,$resiB" ]]; then
        negC_disulfs+=("$formatted_sum,$resiA,$resiB")
    fi
done
# echo "disulfides with ddG < 0 and numDisulfs > 3"
# echo ${negC_disulfs[@]}

# sort by ddG
sorted_array=($(printf "%s\n" "${negC_disulfs[@]}" | sort -r))
# echo "disulfides sorted by ddG with ddG < 0 and numDisulfs > 3"
# echo ${sorted_array[@]}

# top scoring disulfs
disulf_resis=()

# add top scoring disulfs to list but do not allow for repeat positions
for nC_ds in "${sorted_array[@]}"; do
    IFS=',' read -r ddG resiA resiB <<< "$nC_ds"
    # echo $ddG
    # echo $resiA $resiB
    # echo $nC_ds
    # if nC_ds 2 and 3 are not in disulf_resis
    bool_resiA=false
    bool_resiB=false
    # Loop through the elements of negC array
    for element in "${disulf_resis[@]}"; do
        # Check if the element is exactly equal to resiA
        if [ "$element" == "$resiA" ]; then
            bool_resiA=true
        fi
        # Check if the element is exactly equal to resiB
        if [ "$element" == "$resiB" ]; then
            bool_resiB=true
        fi
    done
    if [[ "$bool_resiA" == false && "$bool_resiB" =~ false ]]; then
        # add nC_ds 2 and 3 to disulf_resis
        # echo adding $resiA $resiB
        disulf_resis+=("$(echo "$nC_ds" | awk -F, '{print $2}')")
        disulf_resis+=("$(echo "$nC_ds" | awk -F, '{print $3}')")
    fi
done

echo disulf resis
echo ${disulf_resis[@]}

#write to file
# header
header=$(head -n 1 ThermoMPNN_inference_${pdb::-4}.csv) 
echo "$header,surface_hydrophobe_or_unpaired_cysteine" > ThermoMPNN_inference_${pdb::-4}_filtered.csv

# ,Model,Dataset,ddG_pred,position,wildtype,mutation,pdb,chain
# 0,ThermoMPNN,interprot_topo01_seq01,0.006237924098968506,0,G,A,interprot_topo01_seq01,A
# negC_B=$(awk -F',' -v variable=$resiB '$7=="C" && $5 == variable { print $4 }' "ThermoMPNN_inference_${pdb::-4}.csv")


# fix resi matching

# body
tail -n +2 ThermoMPNN_inference_${pdb::-4}.csv | while IFS=',' read -r line || [ -n "$description" ]; do
    new_line=
    resi=$(echo "$line" | awk -F',' '{ print $5 + 1 }')
    resn=$(echo "$line" | awk -F',' '{print $7}')
    # Flag to indicate if the number is found
    
    bool_ds=false

    # Loop through the array elements
    for num in "${disulf_resis[@]}"; do
        if [ "$num" -eq "$resi" ]; then
            bool_ds=true
            break
        fi
    done

    bool_sr=false

    # Loop through the array elements
    for num in "${surface_resis[@]}"; do
        if [ "$num" -eq "$resi" ]; then
            bool_sr=true
            break
        fi
    done
    
    if [[ $bool_ds =~ true && $resn == "C" ]]; then
        new_line="$line,1"
        echo "$resi $resn ds"
    elif [[  $bool_sr =~ true && "${hydrophobes[*]}" =~ "$resn" ]]; then
        new_line="$line,1"
        echo "$resi $resn hydro"
    else
        new_line="$line,0"
    fi
    echo $new_line >> ThermoMPNN_inference_${pdb::-4}_filtered.csv
done

