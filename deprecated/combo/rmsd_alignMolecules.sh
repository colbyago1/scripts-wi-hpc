#!/bin/bash

reference="$1"

# Loop through each line in the CSV file
while IFS=',' read -r pdb_filename rest_of_line; do
    if [ -e "$pdb_filename" ]
    then
        # Run the Python script and capture its output
        output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 $pdb_filename --sele1 name CA --sele2 name CA --regex ".*(CYPY).*" --regex ".*(TQNGTSSAC).*" --regex ".*(WLTHLNY).*" --regex ".*(HHPGTDKDQIFL).*" --regex ".*(IPSRI).*" --noOutputPdb)

        # Extract the last word from the output using awk
        rmsd=$(echo "$output" | awk '/RMSD/{print $2}')

        # Redundant
        if [ -z "$rmsd" ]; then

            # Run the Python script and capture its output
            output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 $pdb_filename --sele1 name CA --sele2 name CA --regex ".*(CYPV).*" --regex ".*(TQNGTSSAC).*" --regex ".*(WLTHLNY).*" --regex ".*(HHPGTDKDQIFL).*" --regex ".*(IPSRI).*" --noOutputPdb)

            # Extract the last word from the output using awk
            rmsd=$(echo "$output" | awk '/RMSD/{print $2}')

        fi
        if [ -z "$rmsd" ]; then

            # Run the Python script and capture its output
            output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 $pdb_filename --sele1 name CA --sele2 name CA --regex ".*(CYLY).*" --regex ".*(TQNGTSSAC).*" --regex ".*(WLTHLNY).*" --regex ".*(HHPGTDKDQIFL).*" --regex ".*(IPSRI).*" --noOutputPdb)

            # Extract the last word from the output using awk
            rmsd=$(echo "$output" | awk '/RMSD/{print $2}')

        fi
        if [ -z "$rmsd" ]; then
            rmsd=100.0
        fi

        # Append the RMSD value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$rmsd"
    elif [ -e "${pdb_filename::-9}${pdb_filename:(-4)}" ]
    then
        echo "${pdb_filename::-9}${pdb_filename:(-4)}"
        
        # Run the Python script and capture its output
        output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 "${pdb_filename::-9}${pdb_filename:(-4)}" --sele1 name CA --sele2 name CA --regex ".*(CYPY).*" --regex ".*(TQNGTSSAC).*" --regex ".*(WLTHLNY).*" --regex ".*(HHPGTDKDQIFL).*" --regex ".*(IPSRI).*" --noOutputPdb)

        # Extract the last word from the output using awk
        rmsd=$(echo "$output" | awk '/RMSD/{print $2}')
        
        # Redundant
        if [ -z "$rmsd" ]; then

            # Run the Python script and capture its output
            output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 $pdb_filename --sele1 name CA --sele2 name CA --regex ".*(CYPV).*" --regex ".*(TQNGTSSAC).*" --regex ".*(WLTHLNY).*" --regex ".*(HHPGTDKDQIFL).*" --regex ".*(IPSRI).*" --noOutputPdb)

            # Extract the last word from the output using awk
            rmsd=$(echo "$output" | awk '/RMSD/{print $2}')

        fi
        if [ -z "$rmsd" ]; then

            # Run the Python script and capture its output
            output=$(/home/dwkulp/software/mslib.git/mslib/bin/alignMolecules --pdb1 $reference --pdb2 $pdb_filename --sele1 name CA --sele2 name CA --regex ".*(CYLY).*" --regex ".*(TQNGTSSAC).*" --regex ".*(WLTHLNY).*" --regex ".*(HHPGTDKDQIFL).*" --regex ".*(IPSRI).*" --noOutputPdb)

            # Extract the last word from the output using awk
            rmsd=$(echo "$output" | awk '/RMSD/{print $2}')

        fi
        if [ -z "$rmsd" ]; then
            rmsd=100.0
        fi

        # Append the RMSD value to the line and create a new line
        new_line="$pdb_filename,$rest_of_line,$rmsd"
    else
        # If 'p' doesn't match, keep the line unchanged
        new_line="$pdb_filename,$rest_of_line"
    fi
    # Write the new line to a temporary file
    new_line="${new_line//,,/,}"
    echo "$new_line" >> "$2.output.csv"
done < "$2"

