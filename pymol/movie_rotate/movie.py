# !/usr/bin/env python3

from pymol import cmd
import sys

# Load the PSE file
cmd.load(sys.argv[1])

# Get the list of objects
objects_list = cmd.get_object_list()

frame = 1

for index, obj in enumerate(objects_list):
    # Hide all objects initially
    cmd.hide('everything', 'all')

    # show object
    cmd.show('cartoon', obj)

    for i in range(10):
        # Rotate the object
        cmd.rotate('y', 18, obj)

        # Output the current frame as an image (optional)
        cmd.png(f"{frame:04d}.png", width=800, height=600, ray=1)  # Save each frame as an image
        frame += 1