# !/usr/bin/env python3

from Bio.PDB import PDBParser
from Bio.SeqUtils import seq1
import sys

def pdb_to_fasta(pdb_file, fasta_file):
    p = PDBParser(QUIET=True)
    structure = p.get_structure("protein", pdb_file)

    with open(fasta_file, "w") as output_fasta:
        for model in structure:
            for chain in model:
                sequence = ""
                for residue in chain:
                    if residue.get_id()[0] == " ":
                        three_letter_code = residue.get_resname()
                        one_letter_code = seq1(three_letter_code)
                        sequence += one_letter_code
                if sequence:
                    output_fasta.write(f">{model.id}_{chain.id}\n")
                    output_fasta.write(f"{sequence}\n")
                    
if __name__ == "__main__":
    pdb_file_path = sys.argv[1]   # Replace with your PDB file path
    fasta_file_path = f"{sys.argv[1][:-4]}.fasta"  # Replace with the desired output FASTA file path

    pdb_to_fasta(pdb_file_path, fasta_file_path)