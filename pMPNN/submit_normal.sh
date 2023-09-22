#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --mem=350gb
#SBATCH --time=200:00:00
#SBATCH --output=mpnn_normal.out
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
#The first amino acid in the chain corresponds to 1 and not PDB residues index for now.
design_only_positions="6 8 10 12 14 16 27 29 31 33 35 41 43 45 47 49 67 69 71 73 75 77 84 86 88 90 92 94 111 113 115 117 119 121 123 127 129 131 133 135 137 139 150 152 154 156 158 160" #design only these residues; use flag --specify_non_fixed

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/assign_fixed_chains.py --input_path=$path_for_parsed_chains --output_path=$path_for_assigned_chains --chain_list "$chains_to_design"

python /home/cagostino/work/software/ProteinMPNN/helper_scripts/make_fixed_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_fixed_positions --chain_list "$chains_to_design" --position_list "$design_only_positions" --specify_non_fixed

python /home/cagostino/work/software/ProteinMPNN/protein_mpnn_run.py \
        --jsonl_path $path_for_parsed_chains \
        --chain_id_jsonl $path_for_assigned_chains \
        --fixed_positions_jsonl $path_for_fixed_positions \
        --out_folder $output_dir \
        --num_seq_per_target 10 \
        --sampling_temp "0.1" \
        --seed 37 \
        --batch_size 1 
