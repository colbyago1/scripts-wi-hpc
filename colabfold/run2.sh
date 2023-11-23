#!/bin/bash

# # input_file="$1"

# # # Output.csv will have a file of paths to CF pdbs in a3m folder
# # tail -n +2 $input_file | while IFS=',' read -r file rol || [ -n "$file" ]; do
# #     base=$(basename $file)
# #     path=$(dirname "$(dirname "$file")")

# #     output_dir="${path}/a3m4"
# #     if [ ! -d $output_dir ]
# #     then
# #         mkdir -p $output_dir
# #     fi

# #     # Grab parent name and move those a3m files to a3m2
# #     root="${base%%_seq*}"
# #     ls ${path}/$root*seq[0-9][0-9].a3m
# #     # Exclude or remove seq01 and seq02
# #     cp ${path}/$root*seq[0-9][0-9].a3m ${path}/a3m4
# # done

# # # For every a3m2, run CF
# # path="traditional_mini/dir_v3g_topo01/run*/pmpnn_seqs/seqs/a3m2"
# # for d in $path; do (cd $d && sbatch $HOME/work/scripts/colabfold/pre_gpu.sh); done

# # path="traditional_mini/dir_v3g_topo01/run*/pmpnn_seqs/seqs/a3m2"
# path="."
# for d in $path; do
    
#     cd $d
    
#     # Number of directories to create
#     num_dirs=18

#     # Create directories
#     for ((i = 1; i <= num_dirs; i++)); do
#         output_dir="dir$i"
#         if [ ! -d $output_dir ]; then
#             mkdir -p $output_dir
#         fi
#     done

#     i=1
#     for file in ./*; do
#         # Check if it's a file
#         if [ -f "$file" ]; then
#             # Calculate the destination directory (dir1 to dir10)
#             dest_dir="dir$((i % num_dirs + 1))"
#             # echo $dest_dir
#             # Move the file to the destination directory
#             mv "$file" "$dest_dir/"
#             ((i++))
#         fi
#     done

#     cd -
# done

# for d in $path; do
#     cd $d

#     # Number of directories to create
#     num_dirs=18

#     # Create directories
#     for ((i = 1; i <= num_dirs; i++)); do
#         cd "dir$i"
#         pwd
#         sbatch $HOME/work/scripts/colabfold/pre_gpu.sh
#         cd ..
#     done
#     cd /home/cagostino/work/workspace/prefusion_gp41/rfDiffusion/top
# done

# # Output.csv will have a file of paths to CF pdbs in a3m folder
# tail -n +2 $input_file | while IFS=',' read -r file rol || [ -n "$file" ]; do
#     base=$(basename $file)
#     path=$(dirname "$(dirname "$file")")

#     output_dir="${path}/a3m4"
#     if [ ! -d $output_dir ]
#     then
#         mkdir -p $output_dir
#     fi

#     # Grab parent name and move those a3m files to a3m2
#     root="${base%%_seq*}"
#     ls ${path}/$root*seq[0-9][0-9].a3m
#     # Exclude or remove seq01 and seq02
#     cp ${path}/$root*seq[0-9][0-9].a3m ${path}/a3m4
# done

# input_file="$1"

# # Output.csv will have a file of paths to CF pdbs in a3m folder
# tail -n +2 $input_file | while IFS=',' read -r file rol || [ -n "$file" ]; do
#     base=$(basename $file)
#     path=$(dirname $(dirname $(dirname "$(dirname "$file")")))

#     # Grab parent name and move those a3m files to a3m2
#     root="${base%%-monomer*}"
#     # root="${base%%-*}"
#     echo ${path}/$root
#     output=$(echo "$path" | sed 's#/wistar/kulp/users/cagostino/workspace/prefusion_gp41/rfDiffusion/##' | sed 's#/#_#g')
#     echo ./${output}_${root}
#     # ls ${path}/$root*seq[0-9][0-9].a3m
#     # Exclude or remove seq01 and seq02
#     cp ${path}/$root ./${output}_${root} -r
# done

# # # For every a3m2, run CF
# # path="*mini*/dir_v3g_topo0[12]/run*/pmpnn_seqs/seqs/a3m_2"
# # for d in $path; do (cd $d && sbatch $HOME/work/scripts/colabfold/pre_gpu.sh); done

input_file="$1"

# Output.csv will have a file of paths to CF pdbs in a3m folder
tail -n +2 $input_file | while IFS=',' read -r file rol || [ -n "$file" ]; do
    a3m="${file%%"_unrelaxed"*}.a3m"
    echo $a3m
    output=$(echo "$a3m" | sed 's#/wistar/kulp/users/cagostino/workspace/prefusion_gp41/rfDiffusion/##' | sed 's#/#_#g')
    echo top/${output}
    # ls ${path}/$root*seq[0-9][0-9].a3m
    # Exclude or remove seq01 and seq02
    cp $a3m top/${output}
done