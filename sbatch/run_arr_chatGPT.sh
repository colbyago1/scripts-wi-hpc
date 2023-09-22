#!/bin/bash

(1) File

# Save your positions array to a separate file, for example, positions.txt, with one position per line

# Modify your sbatch command to pass the positions file as an environment variable
    # export POSITIONS_FILE=positions.txt
    # sbatch --export=POSITIONS_FILE job_array_script.sh

# Modify your job_array_script.sh script to read the POSITIONS_FILE environment variable and load the positions array from the file
    # #!/bin/bash

    # #SBATCH --job-name=test
    # #SBATCH --account=wistar
    # #SBATCH --partition=defq
    # #SBATCH --nodes=1
    # #SBATCH --ntasks-per-node=1
    # #SBATCH --cpus-per-task=20
    # #SBATCH --time=00:00:30
    # #SBATCH --array=0-31
    # #SBATCH --output=array_job_%A_task_%a.out
    # #SBATCH --error=array_job_%A_task_%a.err

    # # Load the positions array from the file specified by the environment variable
    # positions=($(cat "$POSITIONS_FILE"))

    # # Get the position corresponding to the task index
    # position=${positions[$SLURM_ARRAY_TASK_ID]}

    # # Command(s) to run:
    # echo "I am processing position: $position"
    # # Add your logic here to use the $position variable as needed

(2) Environment variable

# To submit the job and pass the positions array as an environment variable, you can use the --export option in the sbatch command:
    # export POSITIONS_ARRAY=("position1" "position2" "position3" ...)
    # sbatch --export=POSITIONS_ARRAY job_array_script.sh

# Modify the script to accept the positions array as an environment variable
    # #!/bin/bash

    # #SBATCH --job-name=test
    # #SBATCH --account=wistar
    # #SBATCH --partition=defq
    # #SBATCH --nodes=1
    # #SBATCH --ntasks-per-node=1
    # #SBATCH --cpus-per-task=20
    # #SBATCH --time=00:00:30
    # #SBATCH --array=0-31
    # #SBATCH --output=array_job_%A_task_%a.out
    # #SBATCH --error=array_job_%A_task_%a.err

    # # Get the positions array from the environment variable
    # positions=($POSITIONS_ARRAY)

    # # Get the position corresponding to the task index
    # position=${positions[$SLURM_ARRAY_TASK_ID]}

    # # Command(s) to run:
    # echo "I am processing position: $position"
    # # Add your logic here to use the $position variable as needed

(3)

# See "Job Array Submission with Slurm" from chatGPT from 6 Septemeber 2023 for instructions for nested for loop
