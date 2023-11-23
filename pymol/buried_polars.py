#!/usr/bin/env python3
#!/bin/sh

import pymol
from pymol import cmd, stored
import sys

# Dictionary mapping amino acids to their classification (polar or nonpolar)
amino_acids = {
    'ALA': 'nonpolar',
    'CYS': 'polar',
    'ASP': 'polar',
    'GLU': 'polar',
    'PHE': 'nonpolar',
    'GLY': 'nonpolar',
    'HIS': 'polar',
    'ILE': 'nonpolar',
    'LYS': 'polar',
    'LEU': 'nonpolar',
    'MET': 'nonpolar',
    'ASN': 'polar',
    'PRO': 'nonpolar',
    'GLN': 'polar',
    'ARG': 'polar',
    'SER': 'polar',
    'THR': 'polar',
    'VAL': 'nonpolar',
    'TRP': 'nonpolar',
    'TYR': 'polar',
}

def load_csv(file_path):
    # Assuming your CSV file has columns 'Amino Acid' and 'Hydrophobicity'
    data = {}
    with open(file_path, 'r') as file:
        next(file)  # Skip header
        for line in file:
            fields = line.strip().split(',')
            resi = fields[0]
            SASA_norm = float(fields[1])
            data[resi] = SASA_norm
    return data

def main():

    # load SASA info
    csv_path = sys.argv[2]
    data = load_csv(csv_path)

    # load pdb
    pdb_path = sys.argv[1]
    cmd.load(pdb_path) # loads pdb
    pdb = pdb_path[pdb_path.rfind('/') + 1:-4] 

    # Create a selection of polar amino acids
    stored.polar_selection = set()
    cmd.iterate('polymer and not resn NAG', 'stored.polar_selection.add(resn + "-" + resi)')

    # Create selections
    polar_selection_string = '+'.join([res.split("-")[1] for res in stored.polar_selection if amino_acids.get(res.split("-")[0], '') == 'polar'])
    cmd.select("polar", f'resi {polar_selection_string}')

    buried_polar_selection_string = '+'.join([res.split("-")[1] for res in stored.polar_selection if amino_acids.get(res.split("-")[0], '') == 'polar' and data[res.split("-")[1]] <= 0.4])
    cmd.select("buried_polar", f'resi {buried_polar_selection_string}')

    non_buried_polar_selection_string = '+'.join([res.split("-")[1] for res in stored.polar_selection if amino_acids.get(res.split("-")[0], '') == 'polar' and data[res.split("-")[1]] > 0.4])
    cmd.select("non_buried_polar", f'resi {non_buried_polar_selection_string}')

    # Create objects
    cmd.create("obj_buried_polar", "buried_polar")
    cmd.create("obj_non_buried_polar", "non_buried_polar")

    # Sticks
    cmd.show_as("sticks", "obj_buried_polar")
    cmd.show_as("sticks", "obj_non_buried_polar")

    # Color
    cmd.color("yellow", "obj_buried_polar")
    cmd.color("red", "obj_non_buried_polar")

    # Labels
    cmd.create("label_obj_buried_polar", "obj_buried_polar")
    cmd.create("label_obj_non_buried_polar", "obj_non_buried_polar")
    cmd.label("label_obj_buried_polar and name CA", "resn")
    cmd.label("label_obj_non_buried_polar and name CA", "resn")

    cmd.set('transparency', 0.5)
    cmd.show('surface',pdb)

    cmd.save(f"{pdb}_buried_polars.pse") # saves pse

if __name__ == '__main__':
    main()


