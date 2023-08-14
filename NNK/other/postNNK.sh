#!/bin/bash

rm rs* -f
rm slurm* -f
mkdir pdb_output
mkdir csv_output
mv *pdb pdb_output -f
mv *csv csv_output -f
cd csv_output
cat *csv > output.csv
cd ..
