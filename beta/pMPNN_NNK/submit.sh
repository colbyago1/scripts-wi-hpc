#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --mem=350gb
#SBATCH --job-name=mpnn_normal
#SBATCH --gres=gpu:1

folder_with_pdbs="inputs"

output_dir="outputs"
if [ ! -d $output_dir ]
then
    mkdir -p $output_dir
fi

path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"
path_for_assigned_chains=$output_dir"/assigned_pdbs.jsonl"
path_for_fixed_positions=$output_dir"/fixed_pdbs.jsonl"
chains_to_design="A"

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/assign_fixed_chains.py --input_path=$path_for_parsed_chains --output_path=$path_for_assigned_chains --chain_list "$chains_to_design"

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_fixed_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_fixed_positions --chain_list "$chains_to_design"

python /home/cagostino/work/software/ProteinMPNN/protein_mpnn_run.py \
        --jsonl_path $path_for_parsed_chains \
        --chain_id_jsonl $path_for_assigned_chains \
        --fixed_positions_jsonl $path_for_fixed_positions \
        --out_folder $output_dir \
        --num_seq_per_target 1 \
        --sampling_temp "0.1" \
        --seed 0 \
        --batch_size 1 \
        --unconditional_probs_only 1
