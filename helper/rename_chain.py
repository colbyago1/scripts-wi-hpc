from Bio.PDB import PDBParser, PDBIO, Select
import sys

def rename_chain(input_pdb, output_pdb, new_chain_id):
    p = PDBParser(QUIET=True)
    structure = p.get_structure("protein", input_pdb)

    for model in structure:
        for chain in model:
            # Change the chain ID for all residues in the chain
            chain.id = new_chain_id

    # Write the modified structure to the output PDB file
    io = PDBIO()
    io.set_structure(structure)
    io.save(output_pdb)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python rename_chain.py input.pdb output.pdb new_chain_id")
        sys.exit(1)

    input_pdb_path = sys.argv[1]
    output_pdb_path = sys.argv[2]
    new_chain_id = sys.argv[3]

    rename_chain(input_pdb_path, output_pdb_path, new_chain_id)
