#!/bin/bash

pdb=$1

# extract chain
grep '^ATOM\s\+[0-9]\+\s\+.*\s\+A\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-A.pdb
grep '^ATOM\s\+[0-9]\+\s\+.*\s\+B\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-B.pdb
grep '^ATOM\s\+[0-9]\+\s\+.*\s\+C\s\+[0-9]\+\s\+' $pdb > ${pdb::-4}-C.pdb

cat ${pdb::-4}-A.pdb <(echo "TER") ${pdb::-4}-C.pdb <(echo "TER") ${pdb::-4}-B.pdb <(echo "TER") <(echo "END") > ${pdb::-4}-aln.pdb
rm ${pdb::-4}-A.pdb ${pdb::-4}-B.pdb ${pdb::-4}-C.pdb