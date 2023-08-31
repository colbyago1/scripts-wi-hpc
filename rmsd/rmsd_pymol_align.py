# !/usr/bin/env python3

import sys
from pymol import cmd, stored, util

cmd.load(sys.argv[1])
cmd.load(sys.argv[2])

pdb = sys.argv[1][sys.argv[1].rfind('/') + 1:-4] 
ref = sys.argv[2][sys.argv[2].rfind('/') + 1:-4]

# Select chain A from both proteins
cmd.select('pdb_a', f"{pdb} and chain A")
cmd.select('ref_a', f"{ref} and chain A")

# # use PyMOL to get a sequence alignment of the two objects (don't do any refinement to get a better fit - just align the sequences)
# cmd.align('pdb_a', 'ref_a', object="alignment", cycles=0 )

# after doing the sequence alignment, use super to do a sequence-independent, structure-based alignment. supposedly much better than align.
print(cmd.align('pdb_a', 'ref_a')[0])

# Select chain B from ref
# cmd.select('ref_b', f"{ref} and chain B")

# Combine selected chains into a single object
# cmd.create("combined_chains", "pdb_a or ref_b")

# Save the combined structure to a single PDB file
# cmd.save(f"{pdb}.align.pdb", "combined_chains")

# from Bio.PDB import PDBParser, Superimposer, PDBIO
# import sys

# # Instantiate a PDB parser
# pdb_parser = PDBParser(QUIET = True)

# # Parse the structures
# structure_1 = pdb_parser.get_structure('STRUCTURE1', sys.argv[2])
# structure_2 = pdb_parser.get_structure('STRUCTURE2', sys.argv[1])

# # Select the first model from each structure
# model_1 = structure_1[0]['A']
# model_2 = structure_2[0]['A']

# # Get backbone atoms from each model
# atoms_model_1 = [atom for atom in model_1.get_atoms() if atom.name in ['N', 'CA', 'C']]
# atoms_model_2 = [atom for atom in model_2.get_atoms() if atom.name in ['N', 'CA', 'C']]

# # Make sure the two structures have the same number of atoms
# assert len(atoms_model_1) == len(atoms_model_2), "Structures have different numbers of atoms"

# # Create a Superimposer instance
# super_imposer = Superimposer()

# # Apply the superimposition on the atom vectors of the first model of each structure
# super_imposer.set_atoms(atoms_model_1, atoms_model_2)

# # Apply the transformation to the atoms of model_2
# for atom in model_2.get_atoms():
#     atom.transform(super_imposer.rotran[0], super_imposer.rotran[1])

# # Save the aligned structure
# io = PDBIO()
# io.set_structure(structure_2)
# io.save(sys.argv[1][:-4] + '.align.pdb')