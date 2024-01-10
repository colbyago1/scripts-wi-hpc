# !/usr/bin/env python3

# make all objects visible and center first (and visible)

from readline import set_completion_display_matches_hook
from pymol import cmd
import sys

# Load the PSE file
cmd.load(sys.argv[1])

# Get the list of objects
objects_list = cmd.get_object_list()

for index, obj in enumerate(objects_list):
    # if index > 9:
    # Hide all objects initially
    cmd.hide('everything', 'all')

    # show object
    cmd.show('cartoon', obj)
    cmd.show('sticks', f'{obj} and epitope and resn asn')

    # Save the original view as 'scene_original'
    cmd.scene(f'{index+1:03d}', 'store')

cmd.save(f"{sys.argv[1][:-4]}.movie.pse")

print(f"mset 1x{len(objects_list)*30}")

for i in range(len(objects_list)):
    formatted_number_1 = f'{i+1:03d}'
    time = int((len(objects_list)*30/len(objects_list)*i)+1)
    print(f"mview store,  {time}, scene={formatted_number_1}")

# check image size (something like 400x3000 is not ideal)
    
# 15-19 designs @ *40 = 20-24 sec
# 50 designs @ *30 = 50 sec