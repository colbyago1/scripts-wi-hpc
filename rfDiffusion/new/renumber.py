# !/usr/bin/env python3

import sys
from Bio.PDB import PDBIO, PDBParser
import warnings

warnings.filterwarnings('ignore')

io = PDBIO()
parser = PDBParser()

# Check if the correct number of arguments is provided
if len(sys.argv) != 2:
    print("Usage: python script.py <pdb_file>")
    sys.exit(1)

# Get the filename from the command-line argument
pdb_file = sys.argv[1]

# Parse the PDB file
my_pdb_structure = parser.get_structure('test', pdb_file)

# renumber residue in my_pdb_structure
residue_N = 1000
for model in my_pdb_structure:
    for chain in model:
            for residue in chain:
                print(residue.id)
                residue.id = (residue.id[0], residue_N, " ")
                print('----',residue.id)
                residue_N += 1

# renumber residue in my_pdb_structure
residue_N = 1
for model in my_pdb_structure:
    for chain in model:
            for residue in chain:
                print(residue.id)
                residue.id = (residue.id[0], residue_N, " ")
                print('----',residue.id)
                residue_N += 1

# Output renumbered structure
print('\nStructure with renumbered atoms:\n___________________________________')
for model in my_pdb_structure:
    for chain in model:
        for residue in chain:
            print(residue, residue.id)

# Save renumbered structure to a new PDB file
output_filename = pdb_file.split('.')[0] + '_renumb.pdb'
io.set_structure(my_pdb_structure)
io.save(output_filename, preserve_atom_numbering=True)