# !/usr/bin/env python3

import sys
from Bio.PDB import PDBParser
from Bio.PDB.PDBIO import PDBIO

parser = PDBParser()
io = PDBIO()

structure = parser.get_structure(sys.argv[1][:-4], sys.argv[1])
pdb_chains = structure.get_chains()
for chain in pdb_chains:
    if chain.id == sys.argv[2]:
        io.set_structure(chain)
        io.save(structure.get_id() + "_chain" + chain.get_id() + ".pdb")

