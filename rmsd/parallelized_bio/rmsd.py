import argparse
from Bio.PDB import PDBParser, Superimposer
from collections import defaultdict

def reorder_chains(structure, reference_structure):
    chain_order = [chain.id for chain in reference_structure[0]]
    reordered_structure = defaultdict(list)

    for model in structure:
        for chain_id in chain_order:
            if chain_id in model:
                reordered_structure[model.id].append(model[chain_id])

    return reordered_structure

def calculate_backbone_rmsd(structure_1_path, structure_2_path):
    pdb_parser = PDBParser(QUIET=True)

    structure_1 = pdb_parser.get_structure('STRUCTURE1', structure_1_path)
    structure_2 = pdb_parser.get_structure('STRUCTURE2', structure_2_path)

    reordered_structure_2 = reorder_chains(structure_2, structure_1)

    atoms_model_1 = []
    atoms_model_2 = []

    for chain in structure_1[0]:
        atoms_model_1.extend([atom for atom in chain.get_atoms() if atom.name in ['N', 'CA', 'C']])
        atoms_model_2.extend([atom for atom in reordered_structure_2[structure_1[0].id][0].get_atoms() if atom.name in ['N', 'CA', 'C']])
        reordered_structure_2[structure_1[0].id].pop(0)

    assert len(atoms_model_1) == len(atoms_model_2), "Structures have different numbers of atoms"

    super_imposer = Superimposer()
    super_imposer.set_atoms(atoms_model_1, atoms_model_2)

    return super_imposer.rms

def main():
    parser = argparse.ArgumentParser(description='Calculate backbone RMSD of two protein structures.')
    parser.add_argument('structure_1', type=str, help='Path to the first structure (.pdb) file')
    parser.add_argument('structure_2', type=str, help='Path to the second structure (.pdb) file')

    args = parser.parse_args()

    rmsd = calculate_backbone_rmsd(args.structure_1, args.structure_2)
    print(args.structure_1, ",", args.structure_2, ",", rmsd)

if __name__ == "__main__":
    main()
