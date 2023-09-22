#!/bin/bash

# Replace this with the path to your PDB file
file="$1"

# Process the input file and create the output file
sed 's/SCORE:/\n&/2' "$file" > "clean_$file"



