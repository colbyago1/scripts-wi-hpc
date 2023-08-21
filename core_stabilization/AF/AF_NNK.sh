#!/bin/bash

input_fasta=("815-1-18_GL_HC_dock_run083_0007_0001_chainA.fasta")
aminos=(G A L M F W K Q E S P V I C Y H R N D T)

wt_seq=$(sed -n '2p' "$input_fasta")
seq_len=${#wt_seq}
positions=($(seq 1 $seq_len))

for i in "${positions[@]}"
do
    for j in "${aminos[@]}"
    do
        # change the ith position of wt_seq to j
        if [[ $j != ${wt_seq:i-1:1} ]]
        then
            modified_seq=${wt_seq:0:i-1}$j${wt_seq:i}
            echo "$modified_seq"
            output_fasta="${pdb:0:-6}__$i$j.fa"
            echo "> Modified sequence - Position $i to $j" > "$output_file"
            echo "$modified_seq" >> "$output_file"
        fi
    done
done

for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
        do
        	sleep 1
        done
	sbatch submit.sh "$f"
done