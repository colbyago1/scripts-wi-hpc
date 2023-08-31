# !/usr/bin/env python3

from Bio.PDB import PDBParser
from Bio.SeqUtils import seq1
import sys
import re

def pdb_to_seq(pdb_file):
    p = PDBParser(QUIET=True)
    structure = p.get_structure("protein", pdb_file)

    for model in structure:
        for chain in model:
            sequence = ""
            for residue in chain:
                if residue.get_id()[0] == " ":
                    three_letter_code = residue.get_resname()
                    one_letter_code = seq1(three_letter_code)
                    sequence += one_letter_code
    print(sequence)
    return sequence

def checkSequons(pdb_name, seq):
    pattern = r'N.{1}[ST]'
    matches = re.finditer(pattern, seq)
    positions = [match.start() for match in matches]
    print(pdb_name, positions)

if __name__ == "__main__":
    pdb_file_path = sys.argv[1]   # Replace with your PDB file path
    pdb_name = f"{sys.argv[1][:-4]}"

    seq = pdb_to_seq(pdb_file_path)
    checkSequons(pdb_name, seq)