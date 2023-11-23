#!/bin/bash
#SBATCH --job-name=r_matBG18
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=50Gb
#SBATCH --array=1-50%20
#SBATCH --output=logs/BG18mat_rfdiff_%A_%a.out
#SBATCH --error=logs/BG18mat_rfdiff_%A_%a.err


j=${SLURM_ARRAY_TASK_ID}

dir2=`printf "BG18mat_run%03d" $j`;
mkdir -p $dir2;
cd $dir2;
out=`printf "%s/BG18mat" $dir2`;

source ~/.bashrc
module load CUDA
conda activate RFdif7
export PYTHONPATH=/home/dwkulp/software/miniconda3/envs/RFdif7/lib/python3.9/site-packages/:/home/dwkulp/software/miniconda3/lib/python3.9/site-packages/:/home/dwkulp/software/Rosetta-DL/Rosetta-DL/RFdiffusion/env/SE3Transformer/


script='/home/dwkulp/software/Rosetta-DL/Rosetta-DL/RFdiffusion/run_inference.py'

# Here, we're designing binders to insulin receptor, without specifying the topology of the binder a prior
# We first provide the output path and input pdb of the target protein (insulin receptor)
# We then describe the protein we want with the contig input:
#   - residues 1-150 of the A chain of the target protein
#   - a chainbreak (as we don't want the binder fused to the target!)
#   - A 70-100 residue binder to be diffused (the exact length is sampled each iteration of diffusion)
# We tell diffusion to target three specific residues on the target, specifically residues 59, 83 and 91 of the A chain
# We make 10 designs, and reduce the noise added during inference to 0, to improve the quality of the designs

$script inference.output_prefix=$out inference.input_pdb=../BG18_mature_clean.pdb 'contigmap.contigs=[H1-234/0 40-80]' 'ppi.hotspot_res=[H101,H102,H103,H104,H110]' inference.num_designs=1000 denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0 inference.ckpt_override_path=/home/dwkulp/software/Rosetta-DL/Rosetta-DL/RFdiffusion/models/Complex_beta_ckpt.pt

cd ..
