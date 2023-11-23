#!/bin/bash

# #SBATCH --job-name=p_V3g
# #SBATCH --partition=gpu
# #SBATCH --exclude=node050,node051,node052,node053,node054,node056
# #SBATCH --nodes=1
# #SBATCH --ntasks=1
# #SBATCH --export=ALL
# #SBATCH --gres=gpu:1
# #SBATCH --mem=12Gb

source ~/.bashrc
micromamba activate SE3nv

folder_with_pdbs="./"

output_dir="./pmpnn_seqs"
if [ ! -d $output_dir ]
then
    mkdir -p $output_dir
fi

path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"
path_for_tied_positions=$output_dir"/tied_pdbs.jsonl"
path_for_fixed_positions=$output_dir"/fixed_pdbs.jsonl"
chains_to_design="A B C"

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_tied_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_tied_positions --homooligomer 1

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_fixed_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_fixed_positions --chain_list "$chains_to_design" --position_list "$1" --specify_non_fixed

python /home/cagostino/work/software/ProteinMPNN/protein_mpnn_run.py \
        --jsonl_path $path_for_parsed_chains \
        --tied_positions_jsonl $path_for_tied_positions \
        --fixed_positions_jsonl $path_for_fixed_positions \
        --out_folder $output_dir \
        --num_seq_per_target 10 \
        --sampling_temp "0.1" \
        --batch_size 1