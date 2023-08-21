# !/usr/bin/env python3

import sys
from Bio import SeqIO

def pdb2seq(filename, chain=''):
    if chain != '':
        with open(filename, 'r') as pdb_file:
            for record in SeqIO.parse(pdb_file, 'pdb-atom'):
                if 'chain' in record.annotations and record.annotations['chain'] == chain:
                    return str(record.seq)
    else:
        with open(filename, 'r') as pdb_file:
            for record in SeqIO.parse(pdb_file, 'pdb-atom'):
                return str(record.seq)

def findMuts(ref,pdb,chain):
    ref_seq = pdb2seq(ref, chain)
    pdb_seq = pdb2seq(pdb, chain)

    muts = []

    for i, (r, p) in enumerate(zip(ref_seq, pdb_seq)):
        if r != p:
            muts.append(i)

    return len(muts)

muts = findMuts(sys.argv[2],sys.argv[1],'A')
print(muts)





