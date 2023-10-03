#!/usr/bin/env python3
# Colors based on hydrophobicity

import pymol
from pymol import cmd
import sys

def load_csv(file_path):
    # Assuming your CSV file has columns 'Amino Acid' and 'Hydrophobicity'
    data = {}
    with open(file_path, 'r') as file:
        next(file)  # Skip header
        for line in file:
            fields = line.strip().split(',')
            amino_acid = fields[0]
            hydrophobicity = float(fields[1])
            data[amino_acid] = hydrophobicity
    return data

def set_b_factors(data):
    for amino_acid, hydrophobicity in data.items():
        cmd.alter(f'resn {amino_acid}', f'b={hydrophobicity}')

def color_by_b_factor():
    # Color the structure by B factor
    cmd.spectrum('b', 'blue_white_red')  # Change 'your_object_name' to your actual object name

def main():
    
    csv_file_path = '/home/cagostino/work/scripts/pymol/hydrophobicity_table.csv'
    data = load_csv(csv_file_path)

    pdb_path = sys.argv[1]
    cmd.load(pdb_path) # loads pdb
    pdb = pdb_path[pdb_path.rfind('/') + 1:-4] 

    set_b_factors(data)
    color_by_b_factor()
    cmd.set('transparency', 0.25)
    cmd.show('surface')

    cmd.save(f"{pdb}_hydrophobicity.pse") # saves pse

    print("Red = hydrophobic\nBlue = hydrophilic")

if __name__ == '__main__':
    main()
