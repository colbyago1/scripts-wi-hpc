#!/bin/sh

# input protein
pdb="$1"

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
            while [ $(squeue -u cagostino -t pending | wc -l) -gt 5 ]
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
echo "description,numDisulfs" > output.csv
for i in "${positions[@]}"
do
    for j in "${positions[@]}"
    do
        if [ -f "${pdb:0:-4}_C$i-C$j.log" ]
        then
            # Use grep to find the line containing the desired pattern
            line=$(grep 'DATA' "${pdb:0:-4}_C$i-C$j.log")
            # Check if the line is not empty (i.e., it exists)
            if [ -n "$line" ]
            then
                # Use awk to extract the float value from the end of the line
                numDisulfs=$(echo "$line" | awk '{print $6}')

                #write to csv
                echo "${pdb:0:-4}_C$i-C$j.pdb,$numDisulfs" >> output.csv
            fi
        fi
    done
done
