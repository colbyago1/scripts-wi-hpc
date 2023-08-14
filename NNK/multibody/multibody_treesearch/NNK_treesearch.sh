#!/bin/sh

depth=5 # number of mutations
partners="A_B"
pdb=("815-1-18_GL_HC_dock_run083_0007_0001.pdb")
CUTOFF_PERCENTAGE=0.9
positions=(123 125 139 141 236 237 238 239 242)
aminos=(G A L M F W K Q E S P V I C Y H R N D T)

# Array to store job IDs
job_ids=()

# WT
python mutate_wt.py "$pdb" "$partners"
read wt_unbound wt_nrg < "wt"

index=0

while [ $index -lt $depth ]
do
    echo "index: $index"
    echo "partners: ${pdb[@]}"
    for p in "${pdb[@]}"
    do
        for i in "${positions[@]}"
        do
            for j in "${aminos[@]}"
            do
                if [[ $p != *"__${i}"* ]]
                then
                    while [ $(squeue -u cagostino -t running,pending | wc -l) -gt 250 ]
                    do
                        sleep 1
                    done
                    # Submit the job and capture the job ID
                    job_id=$(sbatch run.sh $p $i $j $partners $wt_nrg | awk '{print $4}')
                    job_ids+=("$job_id")
                fi
            done
        done
    done

    for job_id in "${job_ids[@]}"
    do
        while squeue -j "$job_id" 2>/dev/null | grep -q "$job_id"
        do
            sleep 1
        done
        # rm "slurm-$job_id.out"
    done

    # remove resfiles
    # for p in "${pdb[@]}"
    # do
    #     for i in "${positions[@]}"
    #     do
    #         for j in "${aminos[@]}"
    #         do
    #             if [[ $p != *"__${i}"* ]]
    #             then
    #                 rm "rs${p:0:-4}__$i$j"
    #             fi
    #         done
    #     done
    # done

    # Clear arrays
    job_ids=()
    best_pose=()

    for p in "${pdb[@]}"
    do
        if [ -f "${p:0:-4}.csv" ]
        then
            # top n designs
            best_pose+=($(python findbestpose.py $p $wt_unbound $((depth - index)) $CUTOFF_PERCENTAGE))
            # rm "${p:0:-4}.csv"
        fi
    done

    # increment index
    ((index++))

    #set pdb to pose
    pdb=("${best_pose[@]}")
done

# python /home/cagostino/work/scripts/NNK/multibody_treesearch/top_designs.py $wt_unbound $CUTOFF_PERCENTAGE $depth
echo "done"
