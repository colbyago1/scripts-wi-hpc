# !/usr/bin/env python3

import sys

def findMuts(ref,pdb,chain):

    muts = []
    identifier = []

    for i, (r, p) in enumerate(zip(ref, pdb)):

        if r != p:
            muts.append(i)
            identifier.append('*')
        else:
            identifier.append(' ')

    print(pdb)
    print(identifier)
    
    return len(muts)

muts = findMuts(sys.argv[2],sys.argv[1],'A')
print(muts)