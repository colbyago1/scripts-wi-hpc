#!/usr/bin/env python3

from glob import glob
import json
import os
import shutil

json_files = glob('./*/ranking_debug.json')
#print(json_files[0])

os.makedirs('output_files')
csv_file_path = "output_files/AF.csv"
with open(csv_file_path, mode='w') as csv_file:
    csv_file.write("filename,plddts" + '\n')

# Loop through the JSON files
for json_file_path in json_files:
    with open(json_file_path, 'r') as json_file:
        data = json.load(json_file)
        tm = list(data.keys())[0]
        # print(tm)
        tm_keys = list(data[tm].keys()) # list of pdb names
        # print(tm_keys)
        tm_values = [data[tm].get(tk) for tk in tm_keys] # list of tm vals
        # print(tm_values)

        # old file names
        pdb_file_path = json_file_path.rsplit('/', 1)[0] # original path
        old_pdb_files = [pdb_file_path + "/relaxed_" + tk + ".pdb" for tk in tm_keys]
        # print(old_pdb_files)
        
        # new file names
        seq_name = pdb_file_path.rsplit('/', 1)[1] # original path
        # print(seq_name)
        new_pdb_files = [seq_name + "_relaxed_" + tk + ".pdb" for tk in tm_keys]
        # print(new_pdb_files)

        # move files
        for old,new in zip(old_pdb_files,new_pdb_files):
            shutil.copy(old, 'output_files/' + new)

        # Write the row to the CSV file
        with open(csv_file_path, mode='a') as csv_file:
            for filename,tm in zip(new_pdb_files,tm_values):
                csv_file.write(f"{filename},{tm}" + '\n')
        





# # Access data
# print(data['key'])  # Replace 'key' with the actual key in your JSON

# # Modify data
# data['new_key'] = 'new_value'

# # Save data back to the JSON file
# with open('data.json', 'w') as json_file:
#     json.dump(data, json_file, indent=4)  # Write JSON data back to file with formatting
