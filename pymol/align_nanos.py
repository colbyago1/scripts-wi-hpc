# !/usr/bin/env python3
# Aligns nanos

from pymol import cmd

# template = "7X7M"
# unit = "/Users/colbyagostino/projects/CCL27_Nanoparticle_Design/AF/n460-trCCL27_MOUSE/n460-trCCL27_MOUSE.pdb"

# template = "2YF2"
# unit = "/Users/colbyagostino/projects/CCL27_Nanoparticle_Design/AF/trCCL27_MOUSE-IMX/trCCL27_MOUSE-IMX.pdb"

# template = "3EGM"
# unit = "/Users/colbyagostino/projects/CCL27_Nanoparticle_Design/AF/trCCL27_MOUSE-FR/trCCL27_MOUSE-FR.pdb"

# template = "7X7M"
# unit = "/Users/colbyagostino/projects/CCL27_Nanoparticle_Design/AF/sGT60-trCCL27_MOUSE/sGT60-trCCL27_MOUSE.pdb"

# template = "7X7M"
# unit = "/Users/colbyagostino/projects/CCL27_Nanoparticle_Design/AF/trCCL27_MOUSE-sGT60/trCCL27_MOUSE-sGT60.pdb"

template = "7X7M"
unit = "/Users/colbyagostino/Downloads/test.pdb"


unit_name = unit[unit.rfind('/') + 1:-4]

cmd.fetch(template)
cmd.load(unit)


# Get the list of chain names in the 24-mer
chain_names = cmd.get_chains(template)
# Create a list to store the names of the copied subunits
unit_copies = []

# Copy the subunit 24 times
for i in range(len(chain_names)):
    copy_name = f"unit_copy_{i}"
    cmd.create(copy_name, unit_name)
    unit_copies.append(copy_name)

# Align each copy of the subunit to each chain of the 24-mer
for i, copy_name in enumerate(unit_copies):
    align_command = f"align {copy_name}, {template} and chain {chain_names[i]}"
    cmd.do(align_command)

cmd.save(f"align_nanos_{unit_name}.pse") # saves pse