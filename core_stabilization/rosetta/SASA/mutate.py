# !/usr/bin/env python3
#Mutate a single position, repack around it and computes energy

import optparse
from pyrosetta import *
init()

from pyrosetta import PyMOLMover
from pyrosetta.rosetta.core.scoring import *
from pyrosetta.rosetta.core.pack.task import *
from pyrosetta.rosetta.protocols import *
from pyrosetta.rosetta.protocols.geometry import *
from pyrosetta.rosetta.protocols.relax import FastRelax

def mutate(pdb_filename, posi, amino):
    #main function for mutation
    pose = Pose()
    pose_from_file(pose, pdb_filename)

    #Initiate test pose
    testPose = Pose()
    testPose.assign(pose)

    #Initiate energy function
    scorefxn = get_fa_scorefxn()

    #Variables initiation
    name = pdb_filename[:-4]+'__'+str(posi)+str(amino)

    pack(testPose, posi, amino, 'rs'+name, scorefxn)
    testPose.dump_pdb(name + '.pdb')

#Return wild type amino acid
def wildtype(aatype = 'AA.aa_gly'):
    AA = ['G','A','L','M','F','W','K','Q','E','S','P'
            ,'V','I','C','Y','H','R','N','D','T']

    AA_3 = ['AA.aa_gly','AA.aa_ala','AA.aa_leu','AA.aa_met','AA.aa_phe','AA.aa_trp'
            ,'AA.aa_lys','AA.aa_gln','AA.aa_glu', 'AA.aa_ser','AA.aa_pro','AA.aa_val'
            ,'AA.aa_ile','AA.aa_cys','AA.aa_tyr','AA.aa_his','AA.aa_arg','AA.aa_asn'
            ,'AA.aa_asp','AA.aa_thr']

    for i in range(0, len(AA_3)):
        if(aatype == AA_3[i]):
            return AA[i]

def pack(pose, posi, amino, resfile, scorefxn):
    #Generate Design
    specific_design = design(pose, posi)
    specific_design[posi] = 'PIKAA '  + ' ' + str(amino)
    #specific_design = {posi: 'PIKAA '+' '+str(amino)}
    write_resfile(pose, resfile,
        pack = False, design = False , specific = specific_design)

    #Perform The Move
    task_design = TaskFactory.create_packer_task(pose)
    rosetta.core.pack.task.parse_resfile(pose, task_design,
        resfile)
    designmover = minimization_packing.PackRotamersMover(scorefxn, task_design)
    designmover.apply(pose)

#Unbind the pose
def unbind(pose, partners):
    docking.setup_foldtree(pose, partners, Vector1([-1,-1,-1]))
    trans_mover = rigid.RigidBodyTransMover(pose, 1)
    trans_mover.step_size(100)
    trans_mover.apply(pose)

#Generate Specific Designs
def design(pose, posi):
    design = {}
    for i in range (1, pose.total_residue()+ 1):
        if((center_of_mass(pose,posi,posi)-center_of_mass(pose,i,i)).norm()<6):
            design.update({i: ' NATAA'})
    return design

#Define WriteResfile
def write_resfile(pose, resfilename, pack = True, design = False, input_sc = True,freeze = [], specific = {}):
    # determine the header, default settings
    header = ''
    if pack:
        if not design:
            header += 'NATAA\n'
        else:
            header += 'ALLAA\n# ALLAA will NOT work on bridged Cysteines\n'
    else:
        header += 'NATRO\n'
    if input_sc:
        header += 'USE_INPUT_SC\n'
    to_write = header + 'start\n'
    # add  <freeze>  list to  <specific>  dict
    for i in freeze:
        specific[i] = 'NATRO'
    #  <specific>  is a dictionary with keys() as pose resi numbers
    #    and values as resfile keywords (PIKAA
    # use PDBInfo object to write the resfile
    info = pose.pdb_info()
    # pose_from_sequence returns empty PDBInfo, Pose() makes NULL
    if info and info.nres():
        for i in specific.keys():
            num = pose.pdb_info().number(i)
            chain = pose.pdb_info().chain(i)
            #Write
            to_write += str(num).rjust(4) + str(chain).rjust(3) + '  ' + specific[i] + ' USE_INPUT_SC ' + 'EX 1 LEVEL 4 EX 2 LEVEL 4 EX 3 LEVEL 1 EX 4 LEVEL 1 ' + 'EX_CUTOFF 1' + '\n'
    else:
        for i in specific.keys():
            num = i
            chain = ' '
            to_write += str(num).rjust(4) + str(chain).rjust(3) + '  ' + specific[i] + ' USE_INPUT_SC ' + 'EX 1 LEVEL 4 EX 2 LEVEL 4 EX 3 LEVEL 1 EX 4 LEVEL 1 ' + 'EX_CUTOFF 1' + '\n'

    f = open(resfilename,'w+')
    f.write(to_write)
    f.close()

#Set Up Option Parser
parser = optparse.OptionParser()
parser.add_option('--pdb', dest = 'pdb',
    default = '../test/data/test_in.pdb',    # default example PDB
    help = 'the bound pdb' )

parser.add_option('--posi', dest = 'position',
    default = 1,    # default 1
    help = 'the mutate position' )

parser.add_option('--amino', dest = 'amino',
    default = 'G',    # default 'G'
    help = 'the mutate position' )

(options,args) = parser.parse_args()

# PDB file option
pdb_filename = options.pdb
mutate_position = int(options.position)
amino_acid = options.amino

mutate(pdb_filename, mutate_position, amino_acid)

