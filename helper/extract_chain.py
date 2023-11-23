from Bio.PDB import PDBParser, PDBIO, Select
import sys

class ChainSelector(Select):
    def __init__(self, target_chain_id):
        self.target_chain_id = target_chain_id

    def accept_chain(self, chain):
        # Accept only the specified chain
        return chain.id == self.target_chain_id

    def accept_residue(self, residue):
        return 1

    def accept_atom(self, atom):
        return 1

def save_chain(input_pdb, output_pdb, target_chain_id):
    p = PDBParser(QUIET=True)
    structure = p.get_structure("protein", input_pdb)

    # Create a ChainSelector instance to select the specified chain
    chain_selector = ChainSelector(target_chain_id)

    # Apply the chain selection to the structure
    io = PDBIO()
    io.set_structure(structure)
    io.save(output_pdb, select=chain_selector)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python save_chain.py input.pdb output.pdb target_chain_id")
        sys.exit(1)

    input_pdb_path = sys.argv[1]
    output_pdb_path = sys.argv[2]
    target_chain_id = sys.argv[3]

    save_chain(input_pdb_path, output_pdb_path, target_chain_id)
