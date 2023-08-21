#!/bin/bash

# Replace this with the path to your PDB file
pdb_file="$1"

# Extract chain identifiers from the PDB file
chain_ids=$(grep '^ATOM' "$pdb_file" | awk '{print $5}' | sort -u)

total_length=0

# Iterate over each chain and calculate the length
for chain_id in $chain_ids; do
    chain_length=$(grep "^ATOM.* $chain_id " "$pdb_file" | awk '{print $6}' | sort -n | tail -n 1)
    total_length=$((total_length + chain_length))
done

echo "$total_length"