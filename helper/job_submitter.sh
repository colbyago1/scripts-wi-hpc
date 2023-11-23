#!/bin/bash

while IFS=',' read -r name rol || [ -n "$name" ]; do
    name=$(echo -n "$name" | sed 's/^\xef\xbb\xbf//')
    mkdir "${name}"
    cp 6M0J.pdb "${name}"
    cd $name
    clean_rol=$(echo "$rol" | sed 's/,*\r*$//')
    with_chain=$(echo "$clean_rol" | sed 's/\([0-9]\+\)/\1E/g')
    echo "$name"
    /wistar/kulp/software/slurmq --sbatch "/home/dwkulp/software/Rosetta/main/source/bin/rosetta_scripts.linuxgccrelease -s 6M0J.pdb -include_sugars -beta -write_pdb_link_records -maintain_links -parser:protocol /wistar/kulp/users/ywu/software/tools/Glycan_Scanner/core/glycans_tree_v2020_jw.xml -parser:script_vars positions=$with_chain glycosylation=man9"
    cd ..

done < glycan_positions.csv
