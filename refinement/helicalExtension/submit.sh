#!/bin/bash

n_terminal_deletion_n=1
c_terminal_overlap=12
helical_lengths=(12 24 36 48)

for f in *.a3m; do
    mkdir ${f::-4}
    cp $f ${f::-4}
    cd ${f::-4}

    # remove first letter from lines 3,5,7,etc
    sed -i '3~2s/^.//' "$f"

    for c in /home/cagostino/work/workspace/prefusion_gp41/CCCP/top/*pdb; do
        # get bundle sequence
        bundle_seq=$(cat $c | awk '/^ATOM/ && $3 == "CA" && $5 == "A" {print $4}' | tr '\n' ' ' | sed -e 's/ALA/A/g' -e 's/CYS/C/g' -e 's/ASP/D/g' -e 's/GLU/E/g' -e 's/PHE/F/g' -e 's/GLY/G/g' -e 's/HIS/H/g' -e 's/ILE/I/g' -e 's/LYS/K/g' -e 's/LEU/L/g' -e 's/MET/M/g' -e 's/ASN/N/g' -e 's/PRO/P/g' -e 's/GLN/Q/g' -e 's/ARG/R/g' -e 's/SER/S/g' -e 's/THR/T/g' -e 's/VAL/V/g' -e 's/TRP/W/g' -e 's/TYR/Y/g' -e 's/ //g')
        # echo "bundle  $bundle_seq"
        # remove last 12 from addition
        cropped_seq="${bundle_seq::-$c_terminal_overlap}"
        # echo "cropped $cropped_seq"
        name=$(basename $c)
        name=${name%%_unrelaxed*}
        # echo "name $name"
        for n in ${helical_lengths[@]}; do
            # echo "n $n"
            # get addition sequence
            # echo "crop seq $cropped_seq"
            addition_seq="${cropped_seq: -n}"
            # echo "add  seq $addition_seq"

            # get addition length
            addition_len=${#addition_seq}
            # echo "add len $addition_len"

            echo $f
            head $f

            # add addition to beginning of lines 3 and 5
            sed "3s/^/$addition_seq/; 5s/^/$addition_seq/" "$f" > "${f::-4}_${name}_${addition_len}.a3m"

            # get dash string
            dash_string=""
            for ((i = 1; i <= addition_len; i++)); do
                dash_string="${dash_string}-"
            done

            # echo "ds $dash_string"

            # add dashes to lines 7,9,11,etc
            sed -i "7~2s/^/$dash_string/" "${f::-4}_${name}_${addition_len}.a3m"

            #fix header
            IFS=$'\t'
            read -r header < "$f"
            length=$(echo "$header" | awk '{print $1}')
            length="${length:1}"
            cardinality=$(echo "$header" | awk '{print $2}')
            length=$((length + addition_len - n_terminal_deletion_n))
            sed -i '1s/.*/#'"$length"'\t'"$cardinality"'/' "${f::-4}_${name}_${addition_len}.a3m"
        done
    done
    rm $f
    # run CF
    sbatch $HOME/work/scripts/colabfold/pre_gpu.sh
    cd ..
done
