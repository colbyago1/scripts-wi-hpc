#!/bin/bash
#SBATCH --job-name=pMPNN
#SBATCH --partition=defq
#SBATCH --exclude=node050,node051,node052,node053,node054,node056
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --mem=12Gb
#SBATCH --time=200:00:00

folder_with_pdbs="./"

output_dir="./pmpnn_seqs"
if [ ! -d $output_dir ]
then
    mkdir -p $output_dir
fi

path_for_parsed_chains=$output_dir"/parsed_pdbs.jsonl"
path_for_assigned_chains=$output_dir"/assigned_pdbs.jsonl"
# path_for_fixed_positions=$output_dir"/fixed_pdbs.jsonl"

chains_to_design="A"
#The first amino acid in the chain corresponds to 1 and not PDB residues index for now.
# design_only_positions="6 8 10 12 14 16 27 29 31 33 35 41 43 45 47 49 67 69 71 73 75 77 84 86 88 90 92 94 111 113 115 117 119 121 123 127 129 131 133 135 137 139 150 152 154 156 158 160" #design only these residues; use flag --specify_non_fixed

python /wistar/kulp/users/cagostino/software/ProteinMPNN/helper_scripts/parse_multiple_chains.py --input_path=$folder_with_pdbs --output_path=$path_for_parsed_chains

python /wistar/kulp/users/cagostino/software/ProteinMPNN/helper_scripts/assign_fixed_chains.py --input_path=$path_for_parsed_chains --output_path=$path_for_assigned_chains --chain_list "$chains_to_design"

# python /wistar/kulp/users/cagostino/software/ProteinMPNN/helper_scripts/make_fixed_positions_dict.py --input_path=$path_for_parsed_chains --output_path=$path_for_fixed_positions --chain_list "$chains_to_design" --position_list "$design_only_positions" --specify_non_fixed

python /wistar/kulp/users/cagostino/software/ProteinMPNN/protein_mpnn_run.py \
        --jsonl_path $path_for_parsed_chains \
        --chain_id_jsonl $path_for_assigned_chains \
        --out_folder $output_dir \
        --num_seq_per_target 5 \
        --sampling_temp "0.1" \
        --seed 37 \
        --batch_size 1 

# --fixed_positions_jsonl $path_for_fixed_positions \