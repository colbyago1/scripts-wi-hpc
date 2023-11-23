import sys
from Bio import PDB

pdb_parser = PDB.PDBParser(QUIET=True)
pdb_io = PDB.PDBIO()

structures = []

# Check if there are command-line arguments
if len(sys.argv) < 2:
    print("Usage: python script.py file1.pdb file2.pdb ...")
    sys.exit(1)

# Get PDB file names from command-line arguments
pdb_files = sys.argv[1:-1]
target_file = sys.argv[-1]

for pdb_file in pdb_files:
    structure = pdb_parser.get_structure('temp', pdb_file)
    structures.append(structure)

with open(target_file, 'w') as open_file:
    for struct in structures:
        for model in struct:
            pdb_io.set_structure(model)
            pdb_io.save(open_file)
