#!/usr/bin/env python3

import sys
from itertools import permutations

def swap_string_values(input_str):
    # Split the input string by the '-' delimiter
    parts = input_str.split('-')

    # Reverse the order of the split parts
    reversed_parts = list(reversed(parts))

    # Join the reversed parts back together with the '-' delimiter
    result_str = '-'.join(reversed_parts)

    return result_str

def is_valid_permutation(perm):
    for p in perm:
        if swap_string_values(p) in perm:
            return False
    return True

def is_unqiue_permutation(perm, valid_and_unique_permutations):
    if tuple([swap_string_values(p) for p in perm][::-1]) in valid_and_unique_permutations:
        return False
    return True

def main():
    # Check if at least one command-line argument is provided
    if len(sys.argv) < 2:
        print("Usage: python script_name.py arg1 arg2 ...")
        return

    # The first element of sys.argv is the script name itself, so we skip it
    contigs = sys.argv[1:]

    # Find reverse contigs
    contigs_reverse = [swap_string_values(contig) for contig in contigs]

    # Update contig list
    contigs += contigs_reverse
    
    valid_and_unique_permutations = []
    # Generate all permutations of length 3
    for perm in permutations(contigs, len(contigs) // 2):
        # If there is no forward-reverse pair in the permutation, add it to valid_permutations
        if is_valid_permutation(perm):
            if is_unqiue_permutation(perm, valid_and_unique_permutations):
                valid_and_unique_permutations.append(perm)
                # print(perm)
    # print(len(valid_and_unique_permutations))

    start = '5-30/'
    for perm in valid_and_unique_permutations:
        print('contigmap.contigs=[', end='')
        print(start, end='')
        for p in perm:
            print('A' + p, end='')
            if p != perm[-1]: print('/5-30/', end='')
        print('/0 B1-100]')

if __name__ == "__main__":
    main()