#!/bin/bash

input_file="top_100.txt"  # Replace with your input file name

while IFS= read -r p
do
    # Process each p here
    echo "Processing $p"
    
    # You can perform any other operations with the p here
    cp "output_files/$p.pdb" top100 

done < "$input_file"
