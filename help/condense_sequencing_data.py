from Bio import SeqIO
import sys
import re

def process_fasta(fasta_file):
    sequence_dict = {}
    records = list(SeqIO.parse(fasta_file, "fasta"))
    regex_pattern = re.compile(r'(?:WK|Wk|wK|wk|w|W)(.*?)[-_.]')

    for record in records[1:]:
        current_sequence = str(record.seq)
        substring = 'give me that macaque'
        matches = regex_pattern.findall(record.id)
        if matches:
            substring = matches[0]

        if substring not in sequence_dict:
            sequence_dict[substring] = {'wildtype_count': 0, 'mutants': {}}

        if current_sequence == str(records[0].seq):
            sequence_dict[substring]['wildtype_count'] += 1
        else:
            diff_sequence = ''.join(['-' if wild == mutant else mutant for wild, mutant in zip(str(records[0].seq), current_sequence)])
            sequence_dict[substring]['mutants'][diff_sequence] = sequence_dict[substring]['mutants'].get(diff_sequence, 0) + 1
    return sequence_dict, records[0].seq

if len(sys.argv) != 2:
    print("Usage: python script.py filename")
    sys.exit(1)

fasta_file_path = sys.argv[1]

sequence_dict, wt = process_fasta(fasta_file_path)
wt_dash = "-" * len(wt)

print(f'\n\t\t{wt}')
for substring, info in sequence_dict.items():
    print(f"\nWK{int(substring)}\t")
    sorted_mutants = sorted(info['mutants'].items(), key=lambda x: x[1], reverse=True)
    print_wt = False
    for mutant_sequence, occurrence_count in sorted_mutants:
        if(not print_wt and occurrence_count <= info['wildtype_count'] and info['wildtype_count'] > 0):
            print(f"\tN = {info['wildtype_count']}\t{wt_dash}")
            print_wt = True
        print(f"\tN = {occurrence_count}\t{mutant_sequence}")
print('\n')
