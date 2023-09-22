#!/bin/sh

PDBlist="$1"
wtFA="$2"

seq=$(sed -n '2p' $wtFA)

echo "$seq"

# filter designs based on score and number of hits (optional Pandas task)

# create fastas "(filter based on numDisulfs > 5)"

# Read the file line by line
# Process the file line by line
tail -n +2 "$PDBlist" | while IFS= read -r line
do
    # Use cut to extract the first and last values
    PDBname=$(echo "$line" | cut -d',' -f1)
    numDisulfs=$(echo "$line" | rev | cut -d',' -f1 | rev)
        if [ "$numDisulfs" -gt 5 ]; then
            mutation_info=$(echo "$PDBname" | grep -oP 'C\K\d+' | tail -2 | xargs -n2)
            C1=$(echo "$mutation_info" | awk '{print $1}')
            C2=$(echo "$mutation_info" | awk '{print $2}')
            mutSeq="${seq:0:$C1-1}C${seq:C1}"
            mutSeq="${mutSeq:0:$C2-1}C${mutSeq:C2}"
            echo "$mutSeq"
            echo ">${PDBname::-4}" > "${PDBname::-4}.fa"
            echo $mutSeq >> "${PDBname::-4}.fa"
        fi
done

# NNK
for f in ./*fa
do
	while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
        do
        	sleep 1
        done
	sbatch ~/work/scripts/core_stabilization/rosetta/CC/submit.sh "$f"
done
