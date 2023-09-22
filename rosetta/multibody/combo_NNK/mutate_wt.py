# !/usr/bin/env python3
#Mutate a single position, repack around it and computes energy

import sys
from pyrosetta import *
init()

from pyrosetta import PyMOLMover
from pyrosetta.rosetta.core.scoring import *
from pyrosetta.rosetta.core.pack.task import *
from pyrosetta.rosetta.protocols import *
from pyrosetta.rosetta.protocols.geometry import *
from pyrosetta.rosetta.protocols.relax import FastRelax

#Unbind the pose
def unbind(pose, partners):
    docking.setup_foldtree(pose, partners, Vector1([-1,-1,-1]))
    trans_mover = rigid.RigidBodyTransMover(pose, 1)
    trans_mover.step_size(100)
    trans_mover.apply(pose)

# WT
pose = Pose()
pose_from_file(pose, sys.argv[1])
scorefxn = get_fa_scorefxn()

# # relax
# relax = FastRelax()
# relax.set_scorefxn(scorefxn)
# relax.constrain_relax_to_start_coords(True)
# relax.apply(pose)
# pose.dump_pdb(sys.argv[1][:-4] + '.relax.pdb')

wtbound = scorefxn(pose)
unbind(pose, sys.argv[2])
wtunbound = scorefxn(pose)

f = open('wt','w')
f.write(str(wtunbound) + ' ' + str(wtunbound - wtbound))
f.close()