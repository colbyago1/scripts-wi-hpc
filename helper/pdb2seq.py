#!/usr/bin/env python3

from Bio.PDB import PDBParser
from Bio.SeqUtils import seq1
import argparse
import sys

def pdb_to_fasta(pdb_file, chain_id=None):
    p = PDBParser(QUIET=True)
    structure = p.get_structure("protein", pdb_file)

    for model in structure:
        for chain in model:
            if chain_id is not None and chain.id != chain_id:
                continue  # Skip chains that do not match the specified chain_id
            
            sequence = ""
            for residue in chain:
                if residue.get_id()[0] == " ":
                    three_letter_code = residue.get_resname()
                    one_letter_code = seq1(three_letter_code)
                    sequence += one_letter_code
            if sequence:
                print(str(sequence))
                    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert PDB file to FASTA format.')
    parser.add_argument('pdb_file', help='Path to the PDB file')
    parser.add_argument('-c', '--chain', help='Specify the chain ID to process')

    args = parser.parse_args()
    pdb_file_path = args.pdb_file
    chain_id = args.chain

    pdb_to_fasta(pdb_file_path, chain_id)
