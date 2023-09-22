# !/usr/bin/env python3
# Shows interface residues and contacts

from pymol import cmd, stored
from glob import glob

def show_interface(pdb, ref, cutoff):
    cmd.load(pdb) # loads pdb
    pdb = pdb[pdb.rfind('/') + 1:-4] 
    ref = ref[ref.rfind('/') + 1:-4]
    cmd.align(pdb, ref)
    cmd.color("green", f"{pdb} and chain A and name C*") # color chain B green
    cmd.color("cyan", f"{pdb} and chain B and name C*") # color chain B cyan
    cmd.show("sticks", f"byres({pdb} and chain A within {cutoff} of {pdb} and chain B)") # shows sticks for residues within 3 A of other chain
    cmd.show("sticks", f"byres({pdb} and chain B within {cutoff} of {pdb} and chain A)") # shows sticks for residues within 3 A of other chain
    cmd.distance(f"contacts_{pdb}", f"{pdb} and chain A", f"{pdb} and chain B", cutoff, 0) # finds contacts
    cmd.hide("labels", "contacts*") # hide contacts labels
    cmd.hide("sticks", "hydrogens") # hide hydrogens

def store_interface(pdb, cutoff, dc, cc):
    pdb = pdb[pdb.rfind('/') + 1:-4] 
    # store interface resn+resi
    stored.interfaceresdc = []
    stored.interfacerescc = []
    cmd.iterate(f"byres({pdb} and chain {dc} within {cutoff} of {pdb} and chain {cc})", "stored.interfaceresdc.append(resn+'-'+resi)")
    cmd.iterate(f"byres({pdb} and chain {cc} within {cutoff} of {pdb} and chain {dc})", "stored.interfacerescc.append(resn+'-'+resi)")
    stored.interfaceresdc = list(set(stored.interfaceresdc))
    stored.interfacerescc = list(set(stored.interfacerescc))

    # store interface resi
    stored.interfaceresidc = [idc.split("-", 1)[1] for idc in stored.interfaceresdc]
    stored.interfaceresicc = [icc.split("-", 1)[1] for icc in stored.interfacerescc]

    # For each resi of chain dc, stores contacts from chain cc
    stored.contactsresdc = [[] for idc in stored.interfaceresdc]
    for i, idc in enumerate(stored.interfaceresdc):
        cmd.iterate(f"byres({pdb} and chain {cc} within {cutoff} of {pdb} and chain {dc} and resi {idc})", f"stored.contactsresdc[{i}].append(resn+'-'+resi)")
    stored.contactsresdc = [list(set(cdc)) for cdc in stored.contactsresdc]
    stored.contactsresidc = [[i.split("-", 1)[1] for i in idc] for idc in stored.contactsresdc]

    # For each resi of chain cc, stores contacts from chain dc
    stored.contactsrescc = [[] for icc in stored.interfacerescc]
    for i, icc in enumerate(stored.interfacerescc):
        cmd.iterate(f"byres({pdb} and chain {dc} within {cutoff} of {pdb} and chain {cc} and resi {icc})", f"stored.contactsrescc[{i}].append(resn+'-'+resi)")
    stored.contactsrescc = [list(set(ccc)) for ccc in stored.contactsrescc]
    stored.contactsresicc = [[i.split("-", 1)[1] for i in icc] for icc in stored.contactsrescc]

    # # Print interface resi
    # print("Design chain interface resi: ", stored.interfaceresidc)
    # print("Constant chain interface resi: ", stored.interfaceresicc)
    
    # # Print interface resi+resn
    # print("Design chain interface resn+resi: ", stored.interfaceresdc)
    # print("Constant chain interface resn+resi: ", stored.interfacerescc)

    # # Print contact resi
    # for i, idc in enumerate(stored.interfaceresidc):
    #     print("Design chain resi:", idc)
    #     print(stored.contactsresidc[i])
    # for i, icc in enumerate(stored.interfaceresicc):
    #     print("Constant chain resi:", icc)
    #     print(stored.contactsresicc[i])

    # # Print contact resi+resn
    # for i, idc in enumerate(stored.interfaceresdc):
    #     print("Design chain resn+resi:", idc)
    #     print(stored.contactsresdc[i])
    # for i, icc in enumerate(stored.interfacerescc):
    #     print("Constant chain resn+resi:", icc)
    #     print(stored.contactsrescc[i])

    return stored.interfaceresidc

def find_common_resi(interfaceresi):
    l = [item for sublist in interfaceresi for item in sublist]
    
    # Create a dictionary to count the occurrences of each element
    element_count = {}
    for element in l:
        element_count[element] = element_count.get(element, 0) + 1

    # Filter the array to keep elements that appear n or more times
    result = [element for element, count in element_count.items() if count >= len(interfaceresi)/2]
    
    # Pymol selection
    for index, value in enumerate(result):
        print(value, end='')
        if index < len(result) - 1:
            print('+', end='')
    print('\n')
    # NNK selection
    for index, value in enumerate(result):
        print(value, end='')
        if index < len(result) - 1:
            print(' ', end='')  
    print('\n')
    return result

path = "/Users/colbyagostino/projects/eOD/docking_results/"
ref = "/Users/colbyagostino/projects/eOD/815-1-18_GL_HC.pdb"
outfile = "dock_top5"
cutoff = 5

pdbs = glob(f'{path}*.pdb')

cmd.load(ref)
for p in pdbs: show_interface(p, ref, cutoff)
cmd.save(f"{outfile}.pse") # saves pse

design_chain = 'A'
constant_chain = 'B'

interfaceresi = [store_interface(p, cutoff, design_chain, constant_chain) for p in pdbs]
common_resi = find_common_resi(interfaceresi)

