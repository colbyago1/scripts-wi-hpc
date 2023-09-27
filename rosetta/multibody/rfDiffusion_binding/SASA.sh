#!/bin/sh

p="$1"

# calculate sasa
totalSASA=$(/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $p | awk '{lastword=$NF} END {print lastword}')
binderSASA=$(/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $p --sele "chain A" | awk '{lastword=$NF} END {print lastword}')
AbSASA=$(/home/dwkulp/software/mslib.git/mslib/bin/calculateSasa --pdb $p --sele "chain M+N" | awk '{lastword=$NF} END {print lastword}')
echo "$p,$binderSASA,$AbSASA,$totalSASA,$(echo "$binderSASA + $AbSASA - $totalSASA" | bc)" >> "${p::-4}_SASA.csv"
