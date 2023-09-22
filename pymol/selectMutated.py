# !/usr/bin/env python3
# Shows interface residues and contacts

from pymol import cmd, stored, util
from glob import glob

one_letter ={'VAL':'V', 'ILE':'I', 'LEU':'L', 'GLU':'E', 'GLN':'Q','ASP':'D', 'ASN':'N', 'HIS':'H', 'TRP':'W', 'PHE':'F', 'TYR':'Y', 'ARG':'R', 'LYS':'K', 'SER':'S', 'THR':'T', 'MET':'M', 'ALA':'A','GLY':'G', 'PRO':'P', 'CYS':'C', 'MSE':'M', 'ASX':'N'  , 'HSD' : 'H', 'HSE' : 'H', 'HSP': 'H'}

def select_mutated(pdb, ref, cutoff, dc, cc):
    # loads pdb
    cmd.load(pdb)
    
    pdb = pdb[pdb.rfind('/') + 1:-4] 
    ref = ref[ref.rfind('/') + 1:-4]
    
    # use PyMOL to get a sequence alignment of the two objects (don't do any refinement to get a better fit - just align the sequences)
    cmd.align(pdb, ref, object="alignment", cycles=0 )
    
    # after doing the sequence alignment, use super to do a sequence-independent, structure-based alignment. supposedly much better than align.
    cmd.super(pdb, ref)
    
    # color chains
    cmd.color("green", f"{pdb} and chain {dc} and name C*")
    cmd.color("cyan", f"{pdb} and chain {cc} and name C*")
    
    # shows sticks for residues within 3 A of dc chain
    cmd.show("sticks", f"byres({pdb} and chain {cc} within {cutoff} of {pdb} and chain {dc})") 

    # hide hydrogens
    cmd.hide("sticks", "hydrogens")

    print("selectMutated called with object 1: " + ref + " and object 2: " + pdb)

    # use PyMOL to get a sequence alignment of the two objects (don't do any refinement to get a better fit - just align the sequences)
    cmd.align( pdb, ref, object="alignment", cycles=0 )

    # after doing the sequence alignment, use super to do a sequence-independent, structure-based alignment. supposedly much better than align.
    cmd.super( pdb, ref )
    
    # alignment is an "object" which somehow contains both objects that were used for the alignment. we'll iterate over this alignment object
    # and save the chain, resi, and resn for each aligned position.  making the big assumption here that the order of elements in the alignment
    # object is the same for both actual aligned objects, which seems to be the case. 
    stored.ref_resi = []
    stored.pdb_resi = []
    
    stored.ref_resn = []
    stored.pdb_resn = []
    
    stored.ref_chain = []
    stored.pdb_chain = []

    cmd.iterate( ref + " and n. CA and alignment", "stored.ref_resi.append( resi )" )
    cmd.iterate( pdb + " and n. CA and alignment", "stored.pdb_resi.append( resi )" )

    cmd.iterate( ref + " and n. CA and alignment", "stored.ref_resn.append( resn )" )
    cmd.iterate( pdb + " and n. CA and alignment", "stored.pdb_resn.append( resn )" )

    cmd.iterate( ref + " and n. CA and alignment", "stored.ref_chain.append( chain )" )
    cmd.iterate( pdb + " and n. CA and alignment", "stored.pdb_chain.append( chain )" )


    sele_mutations_list = []
    sele_insert_list = []
    wt_list = []
    mut_list = []
    mutations = []

    # loop over the aligned residues
    for resn1, resn2, resi1, resi2, ch1, ch2 in zip( stored.ref_resn, stored.pdb_resn, stored.ref_resi, stored.pdb_resi, stored.ref_chain, stored.pdb_chain ):
        # take care of 'empty' chain names
        if ch1 == '':
            ch1 = '""'
        if ch2 == '':
            ch2 = '""'
        if resn1 != resn2:
            print("%s/%s-%s => %s/%s-%s" % ( ch1, resn1, resi1, ch2, resn2, resi2 ))
            sele_exp = '/' + '/'.join([ pdb, '', ch2, resi2 ])
            sele_mutations_list.append( sele_exp )
            
            wt_list.append( one_letter[resn1] )
            mut_list.append( one_letter[resn2] )
            mutations.append( "%s:%s%s%s" % ( ch2, one_letter[resn1], resi2, one_letter[resn2]) )

    if not mutations:
        print("No mutations found.\n")
        return

    print(wt_list)
    print(mut_list)

    selename = "mutated-" + pdb
    #print "+".join(sele_mutations_list)
    cmd.select(selename, " + ".join(sele_mutations_list))
    print(f"Mutations found: {mutations}\n")

    cmd.show("sticks", selename)
    hideexp = "(mutated-" + pdb + " and hydro)"
    cmd.hide(hideexp)
    cmd.color( "yellow", selename + " and not (name N+CA+C+O)" )
    util.cnc(selename)
    cmd.disable(selename)

    for i in range(0,len(sele_mutations_list)):
        labelexp = '''"''' + wt_list[i] + '''%s''' + mut_list[i] + '''"''' + ''' % (resi)'''
        cmd.label( sele_mutations_list[i] + " and n. ca", labelexp )
        #labelexp = '''(name ca+C1*+C1' and (byres(mutated-''' + pdb + ''')))'''
        #cmd.label(labelexp,'''"%s-%s"%(resn,resi)''')

    # identify insertions also, by using the mutated selection and alignment object
    # this will be the intersection of everything that's in object2 that's not in the alignment object (will included mutated positions and inserts) and 
    # not anything that's in the mutated selection
    selename = "inserts-" + pdb
    cmd.select( selename, "(" + pdb + " and not hydro and !(" + pdb + " in alignment)) and !(mutated-" + pdb + ")" )
    cmd.color( "orange", selename )
    util.cnc(selename)
    cmd.disable(selename)

    # clean up after ourselves
    cmd.delete("alignment*")
    cmd.delete("inserts*")
    cmd.delete("mutated*")

    
path = "/Users/colbyagostino/projects/eOD/pMPNN_designs/subsub/"
ref = "/Users/colbyagostino/projects/eOD/815-1-18_GL_HC.pdb"
outfile = "pMPNN_designs"
cutoff = 5
design_chain = 'A'
constant_chain = 'B'

pdbs = glob(f'{path}*.pdb')

cmd.load(ref)
for p in pdbs: select_mutated(p, ref, cutoff, design_chain, constant_chain)
cmd.save(f"{outfile}.pse") # saves pse