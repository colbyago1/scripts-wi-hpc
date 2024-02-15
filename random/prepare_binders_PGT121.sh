#!/bin/bash

# declare variables
#length of chains 101 and 102
length_A=108
length_B=133
# msa path
msa_path="/home/cagostino/work/workspace/AbsBinders/sgang/AF/setup/PGT121_CF/PGT121_CF.a3m"
# binder sequence as input
fa="$1"

tail -n +2 $fa | while IFS=',' read -r name pdb seq; do

    # get length of binder
    length_C=${#seq}

    # get binder msa (additions, blanks, dashes)
    dash_string_A=$(printf -- '-%.0s' $(seq 1 "$length_A"))
    dash_string_B=$(printf -- '-%.0s' $(seq 1 "$length_B"))
    dash_string_C=$(printf -- '-%.0s' $(seq 1 "$length_C"))

    # write header and query to file
    echo -e "#${length_A},${length_B},${length_C}\t1,1,1" > ${name}.a3m
    echo -e ">101\t102\t103" >> ${name}.a3m
    echo "$(sed -n "3p" ${msa_path})${seq}" >> ${name}.a3m

    # # Loop through textfiles and create sequences for msa by combining parsed a3m and linkers in order
    # for ((i = 3; i <= line_count; i++)); do
    #     line=$(sed -n "${i}p" ${msa_path})
    #     if ((i % 2 == 1)); then
    #         line+=${dash_string_C}
    #     fi
    #     echo $line >> "${fa::-3}.a3m"
    # done

    awk 'NR >= 4 {
        if (NR % 2 == 1) {
            print $0 dash_string_C
        } else {
            print $0
        }
    }' dash_string_C="$dash_string_C" "${msa_path}" >> "${name}.a3m"


    echo ">103" >> ${name}.a3m 
    echo "${dash_string_A}${dash_string_B}${seq}" >> ${name}.a3m
    echo ">103" >> ${name}.a3m 
    echo "${dash_string_A}${dash_string_B}${seq}" >> ${name}.a3m

done