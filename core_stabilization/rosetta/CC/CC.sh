#!/bin/sh

# input protein
pdb=("815-1-18_GL_HC_dock_run083_0007_0001_chainA.pdb")

# get length of protein
length=$(bash /home/cagostino/work/scripts/core_stabilization/rosetta/CC/findL.sh $pdb)

# get positions
positions=($(seq 1 $length))

# Serialize the array by joining its elements with a delimiter
serialized_array=$(IFS="|" ; echo "${positions[*]}")

# Array to store job IDs
job_ids=()

# run mutate
for i in "${positions[@]}"
do
    while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
    do
        sleep 1
    done
    job_id=$(sbatch /home/cagostino/work/scripts/core_stabilization/rosetta/CC/run_mutate.sh "$pdb" "$i" "$serialized_array" | awk '{print $4}')
    job_ids+=("$job_id")
done

# wait for jobs to finish
for job_id in "${job_ids[@]}"
do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
done

# Array to store job IDs
job_ids=()

# run disulfides
for i in "${positions[@]}"
do
    for j in "${positions[@]}"
    do
        if [ -f "${pdb:0:-4}_C$i-C$j.pdb" ]
        then
            while [ $(squeue -u cagostino -t pending | wc -l) -gt 1 ]
            do
                sleep 1
            done
            # Submit the job and capture the job ID
            job_id=$(sbatch /home/cagostino/work/scripts/core_stabilization/rosetta/CC/run_disulfide.sh ${pdb:0:-4}_C$i-C$j.pdb $i $j | awk '{print $4}')
            job_ids+=("$job_id")
        fi
    done
done

# wait for jobs to finish
for job_id in "${job_ids[@]}"
do
    while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
    do
        sleep 1
    done
done

# create csv
echo "filename,rmsd" > output.csv
for i in "${positions[@]}"
do
    for j in "${positions[@]}"
    do
        if [ -f "${pdb:0:-4}_C$i-C$j.log" ]
        then
            # Use grep to find the line containing the desired pattern
            line=$(grep 'BEST DISFULIDE HAS RMSD:' "${pdb:0:-4}_C$i-C$j.log")
            # Check if the line is not empty (i.e., it exists)
            if [ -n "$line" ]
            then
                # Use awk to extract the float value from the end of the line
                rmsd=$(echo "$line" | awk '{print $NF}')

                #write to csv
                echo "${pdb:0:-4}_C$i-C$j.pdb,$rmsd" >> output.csv
            fi
        fi
    done
done
