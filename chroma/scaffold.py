#!/usr/bin/env python3

from chroma import Protein, Chroma, conditioners

chroma = Chroma(device="cuda")
protein = Protein('../../epitope.pdb', device='cuda')

# selection based on PDB numbering starting at 1
substruct_conditioner = conditioners.SubstructureConditioner(protein, backbone_model=chroma.backbone_network, selection="resid 11-32+43-49+228-234")

for i in range(5000):
    infilled_protein, trajectories = chroma.sample(
                protein_init=protein,
                conditioner=substruct_conditioner,
                langevin_factor=4.0,
                langevin_isothermal=True,
                inverse_temperature=8.0,
                steps=500,
                sde_func="langevin",
                full_output=True) # steps should be 500
    infilled_protein.to(f"1D8_{i:04d}.pdb")

# for i in range(5000):
#     infilled_protein, trajectories = chroma.sample(
#                 protein_init=protein,
#                 conditioner=substruct_conditioner,
#                 langevin_factor=8.0,
#                 inverse_temperature=8.0,
#                 sde_func="langevin",
#                 full_output=True) # steps should be 500
#     infilled_protein.to(f"test_{i}.pdb")