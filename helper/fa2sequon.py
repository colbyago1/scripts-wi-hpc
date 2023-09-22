# !/usr/bin/env python3


import sys
import re

def checkSequons(pdb_name, seq):
    pattern = r'N.{1}[ST]'
    matches = re.finditer(pattern, seq)
    positions = [match.start() for match in matches]
    print(f"{pdb_name},{' '.join(map(str, positions))}")

if __name__ == "__main__":
    pdb_name = f"{sys.argv[1][:-4]}"
    seq = sys.argv[2]
    checkSequons(pdb_name, seq)