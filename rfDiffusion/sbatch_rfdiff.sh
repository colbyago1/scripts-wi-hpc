#!/bin/bash

#SBATCH --job-name=r_V2a
#SBATCH --partition=gpu
#SBATCH --exclude=node050,node051
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --export=ALL
#SBATCH --gres=gpu:1
#SBATCH --mem=50Gb

source ~/.bashrc
module load CUDA
micromamba activate /home/dwkulp/software/miniconda3/envs/RFdif7
export PYTHONPATH=/home/dwkulp/software/miniconda3/envs/RFdif7/lib/python3.9/site-packages/:/home/dwkulp/software/miniconda3/lib/python3.9/site-packages/:/home/dwkulp/software/Rosetta-DL/Rosetta-DL/RFdiffusion/env/SE3Transformer/

#contig="[50/A2-4/50/0 50/A7-9/50/0 50/A12-14/50/0 50/A17-19/50/0]"
#contig="[2-20/A1-13/6-30/A14-36/6-30/A37-50/6-30/0 2-20/A51-63/6-30/A64-86/6-30/A87-100/2-20/0 2-20/A101-113/6-30/A114-136/6-30/A137-150/2-20/0]"
#contig="[20/A1-13/30/A14-36/30/A37-50/30/0 20/A51-63/30/A64-86/30/A87-100/20/0 20/A101-113/30/A114-136/30/A137-150/20/0]"
#contig="[20/A1-13/30/0 20/A51-63/30/0 20/A101-113/30/0]"
#contig="[20/A1-13/30/A14-36/30/0 20/A51-63/30/A64-86/30/0 20/A101-113/30/A114-136/30/0]"

#contig="[20/A1-13/6-30/A14-36/6-30/A37-50/2-20/0 20/A51-63/6-30/A64-86/6-30/A87-100/2-20/0 20/A101-113/6-30/A114-136/6-30/A137-150/2-20/0]"
#contig="[20/A1-13/6-30/A14-36/30/A37-50/2-20/0 20/A51-63/6-30/A64-86/30/A87-100/2-20/0 20/A101-113/6-30/A114-136/30/A137-150/2-20/0]"

#contig="[20/A1-13/30/A14-36/30/A37-50/2-20/0 20/A51-63/30/A64-86/30/A87-100/2-20/0 20/A101-113/30/A114-136/30/A137-150/2-20/0]"
#contig="[20/A1-13/6-30/A14-36/30/A37-50/2-20/0 20/A51-63/6-30/A64-86/30/A87-100/2-20/0 20/A101-113/6-30/A114-136/30/A137-150/2-20/0]"

# This one works, fixed connetions
#contig="[10/A1-13/20/A14-36/20/A37-50/10/0 10/A51-63/20/A64-86/20/A87-100/10/0 10/A101-113/20/A114-136/20/A137-150/10/0]"

ckpt='/home/dwkulp/software/Rosetta-DL/Rosetta-DL/RFdiffusion/models/Base_epoch8_ckpt.pt'


contig=""
if [ "$topo" -eq "1" ]
then
    contig="[10/A1-13/20/A14-36/20/A37-50/10/0 10/A51-63/20/A64-86/20/A87-100/10/0 10/A101-113/20/A114-136/20/A137-150/10/0]"
fi

if [ "$topo" -eq "2" ]
then
    contig="[10/A1-13/20/A37-50/20/A14-36/10/0 10/A51-63/20/A87-100/20/A64-86/10/0 10/A101-113/20/A137-150/20/A114-136/10/0]"
fi

if [ "$topo" -eq "3" ]
then
   contig="[10/A14-36/20/A1-13/20/A37-50/10/0 10/A64-86/20/A51-63/20/A87-100/10/0 10/A114-136/20/A101-113/20/A137-150/10/0]"
fi 

if [ "$topo" -eq "4" ]
then
    contig="[10/A14-36/20/A37-50/20/A1-13/10/0 10/A64-86/20/A87-100/20/A51-63/10/0 10/A114-136/20/A137-150/20/A101-113/10/0]"
fi

if [ "$topo" -eq "5" ]
then
    contig="[10/A37-50/20/A1-13/20/A14-36/10/0 10/A87-100/20/A51-63/20/A64-86/10/0 10/A137-150/20/A101-113/20/A114-136/10/0]"
fi

if [ "$topo" -eq "6" ]
then
    contig="[10/A37-50/20/A14-36/20/A1-13/10/0 10/A87-100/20/A64-86/20/A51-63/10/0 10/A137-150/20/A114-136/20/A101-113/10/0]"
fi

#topo=4
prefix=`printf "V2a_20aa_topo%02d" $topo`

python /home/dwkulp/software/Rosetta-DL/Rosetta-DL/RFdiffusion/run_inference.py inference.symmetry="C3" inference.num_designs=1000 inference.output_prefix=./$prefix 'potentials.guiding_potentials=["type:olig_contacts,weight_intra:1,weight_inter:0.06"]' potentials.olig_intra_all=True potentials.olig_inter_all=True potentials.guide_scale=2 potentials.guide_decay="quadratic" inference.input_pdb=/wistar/kulp/users/ssolieva/projects/test_design/V2apex_rfdiff/TriApexSymSingleChain.pdb "contigmap.contigs=$contig" inference.ckpt_override_path=$ckpt 
