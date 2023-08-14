import argparse
from Bio.PDB import PDBParser, Superimposer

def calculate_backbone_rmsd(structure_1_path, structure_2_path):
    # Instantiate a PDB parser
    pdb_parser = PDBParser(QUIET = True)

    # Parse the structures
    structure_1 = pdb_parser.get_structure('STRUCTURE1', structure_1_path)
    structure_2 = pdb_parser.get_structure('STRUCTURE2', structure_2_path)

    # Select the first model from each structure
    model_1 = structure_1[0]
    model_2 = structure_2[0]

    # Get backbone atoms from each model
    atoms_model_1 = [atom for atom in model_1.get_atoms() if atom.name in ['N', 'CA', 'C']]
    atoms_model_2 = [atom for atom in model_2.get_atoms() if atom.name in ['N', 'CA', 'C']]

    # Make sure the two structures have the same number of atoms
    assert len(atoms_model_1) == len(atoms_model_2), "Structures have different numbers of atoms"

    # Create a Superimposer instance
    super_imposer = Superimposer()

    # Apply the superimposition on the atom vectors of the first model of each structure
    super_imposer.set_atoms(atoms_model_1, atoms_model_2)

    return super_imposer.rms

def main():
    parser = argparse.ArgumentParser(description='Calculate backbone RMSD of two protein structures.')
    parser.add_argument('structure_1', type=str, help='Path to the first structure (.pdb) file')
    parser.add_argument('structure_2', type=str, help='Path to the second structure (.pdb) file')

    args = parser.parse_args()

    rmsd = calculate_backbone_rmsd(args.structure_1, args.structure_2)
    print(args.structure_1,",",args.structure_2,",",rmsd)

if __name__ == "__main__":
    main()
