#!/usr/bin/env python3

import numpy as np
import sys

alphabet = 'ACDEFGHIKLMNPQRSTVWYX'

# Initialize an empty dictionary
my_dict = {}

name = sys.argv[1][:-4]
seq = sys.argv[2]
path = f"outputs/unconditional_probs_only/{name}.npz"
data = np.load(path)
log_p = data['log_p'][0] #Length by 21
for position in range(len(log_p)):
    wt_amino_index = alphabet.index(seq[position])
    wt_log_p = log_p[position][wt_amino_index]
    for amino in range(len(log_p[position]) - 1):
        if amino != wt_amino_index:
            my_dict[f"{alphabet[wt_amino_index]}{position+1}{alphabet[amino]}"] = float(log_p[position][amino] - wt_log_p)

# Sort the list of dictionaries based on value
sorted_dict = dict(sorted(my_dict.items(), key=lambda item: item[1]))

print('Mutation\tlog_p(mut/wt)')
for key, value in sorted_dict.items():
    print(f"{key}\t{value}")

