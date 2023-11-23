#!/bin/bash

wt="$1"
mut="$2"

# Check if the strings are of the same size
if [ ${#wt} -ne ${#mut} ]; then
    echo "Error: Strings are not of the same size (${#wt} ${#mut})"
    exit 1
fi

# Loop through the strings
for ((i=0; i<${#mut}; i++)); do
    if [ "${wt:$i:1}" != "${mut:$i:1}" ]; then
        echo -n "${wt:$i:1}$((i+1))${mut:$i:1} "
    fi
done

echo