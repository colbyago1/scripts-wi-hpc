#!/bin/bash

#SBATCH --job-name=p_V3g
#SBATCH --partition=gpu
#SBATCH --exclude=node050,node051,node052,node053,node054,node056
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=12Gb

source ~/.bashrc
source activate /home/dwkulp/software/miniconda3/envs/pmpnn2

folder_with_pdbs="./"

output_dir="./pmpnn_seqs"
if [ ! -d $output_dir ]
then
    mkdir -p $output_dir
fi

path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"
path_for_assigned_chains=$output_dir"/assigned_pdbs.jsonl"
path_for_fixed_positions=$output_dir"/fixed_pdbs.jsonl"
chains_to_design="A"
chains_to_ignore="B"

python /home/dwkulp/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

python /home/dwkulp/software/ProteinMPNN/helper_scripts/assign_fixed_chains.py --input_path=$path_for_parsed_chains --output_path=$path_for_assigned_chains --chain_list "$chains_to_design"

python /home/dwkulp/software/ProteinMPNN/helper_scripts/createJsonFixedPos.py $folder_with_pdbs $path_for_fixed_positions $chains_to_ignore

python /home/dwkulp/software/ProteinMPNN/protein_mpnn_run.py \
        --jsonl_path $path_for_parsed_chains \
        --chain_id_jsonl $path_for_assigned_chains \
        --fixed_positions_jsonl $path_for_fixed_positions \
        --out_folder $output_dir \
        --num_seq_per_target 5 \
        --sampling_temp "0.1" \
        --batch_size 1

